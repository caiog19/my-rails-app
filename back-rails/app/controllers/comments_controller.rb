class CommentsController < ApplicationController
  # Protege as ações :create, :hide e :reveal com autenticação
  before_action :authorize_request, only: [:create, :hide, :reveal]
  before_action :set_post
  before_action :set_comment, only: [:update, :hide, :reveal]

  # Listar comentários de um post
  def index
    if @current_user&.admin?
      comments = @post.comments.includes(:user).order(created_at: :desc)
    else
      comments = @post.comments.where(hidden: false).includes(:user).order(created_at: :desc)
    end

    render json: comments.map { |comment|
      {
        id: comment.id,
        content: comment.hidden && !@current_user&.admin? ? "Este comentário está oculto." : comment.content,
        author_name: comment.author_name,
        created_at: comment.created_at,
        hidden: comment.hidden
      }
    }
  end

  # Criar um comentário
  def create
    comment = @post.comments.new(comment_params)
    comment.user_id = @current_user&.id 

    if comment.save
      render json: {
        id: comment.id,
        content: comment.content,
        author_name: comment.author_name,
        created_at: comment.created_at
      }, status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Atualizar um comentário
  def update
    if @current_user.admin? || @comment.user_id == @current_user.id
      if @comment.update(comment_params)
        render json: {
          id: @comment.id,
          content: @comment.content,
          author_name: @comment.author_name,
          created_at: @comment.created_at,
          hidden: @comment.hidden
        }, status: :ok
      else
        render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: ["Você não tem permissão para editar este comentário."] }, status: :forbidden
    end
  end

  # Ocultar um comentário
  def hide
    if @current_user.admin?
      if @comment.update(hidden: true)
        render json: { message: "Comentário ocultado com sucesso." }, status: :ok
      else
        render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: ["Apenas administradores podem ocultar comentários."] }, status: :forbidden
    end
  end

  # Revelar um comentário
  def reveal
    if @current_user.admin?
      if @comment.update(hidden: false)
        render json: { message: "Comentário revelado com sucesso." }, status: :ok
      else
        render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: ["Apenas administradores podem revelar comentários."] }, status: :forbidden
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Post não encontrado" }, status: :not_found
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Comentário não encontrado" }, status: :not_found
  end

  def comment_params
    params.require(:comment).permit(:content, :hidden)
  end
end
