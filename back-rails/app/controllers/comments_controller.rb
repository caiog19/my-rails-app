class CommentsController < ApplicationController
  # Protege as ações :create, :hide e :reveal com autenticação
  before_action :authorize_request, only: [:create, :hide, :reveal, :upvote, :downvote]
  before_action :set_post
  before_action :set_comment, only: [:update, :hide, :reveal, :upvote, :downvote]

  # Listar comentários de um post
  def index
    if @current_user&.admin?
      comments = @post.comments.includes(:user, :votes).order(created_at: :desc)
    else
      comments = @post.comments.where(hidden: false).includes(:user, :votes).order(created_at: :desc)
    end
  
    render json: comments.map { |comment|
      current_user_vote = @current_user ? comment.votes.find_by(user: @current_user)&.vote_type : nil
  
      {
        id: comment.id,
        content: comment.hidden && !@current_user&.admin? ? "Este comentário está oculto." : comment.content,
        author_name: comment.author_name,
        created_at: comment.created_at,
        hidden: comment.hidden,
        upvotes: comment.upvotes,
        downvotes: comment.downvotes,
        current_user_vote: current_user_vote
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
        created_at: comment.created_at,
        hidden: comment.hidden,
        upvotes: comment.upvotes,
        downvotes: comment.downvotes,
        current_user_vote: nil
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
      render json: { 
        message: "Comentário ocultado com sucesso.",
        upvotes: @comment.upvotes,
        downvotes: @comment.downvotes,
        current_user_vote: @current_user ? @comment.votes.find_by(user: @current_user)&.vote_type : nil
      }, status: :ok
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
      render json: { 
        message: "Comentário revelado com sucesso.",
        upvotes: @comment.upvotes,
        downvotes: @comment.downvotes,
        current_user_vote: @current_user ? @comment.votes.find_by(user: @current_user)&.vote_type : nil
      }, status: :ok
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  else
    render json: { errors: ["Apenas administradores podem revelar comentários."] }, status: :forbidden
  end
end


  def upvote
    handle_vote('upvote')
  end

  # Ação para downvote
  def downvote
    handle_vote('downvote')
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

  def handle_vote(vote_type)
    existing_vote = @comment.votes.find_by(user: @current_user)
  
    if existing_vote
      if existing_vote.vote_type == vote_type
        # Se o voto atual for do mesmo tipo, remove o voto (toggle off)
        existing_vote.destroy
        message = "Voto removido com sucesso."
      else
        # Se o voto for de tipo diferente, atualiza para o novo tipo
        existing_vote.update!(vote_type: vote_type)
        message = "Voto alterado para #{vote_type}."
      end
    else
      # Cria um novo voto
      @comment.votes.create!(user: @current_user, vote_type: vote_type)
      message = "Voto #{vote_type} registrado com sucesso."
    end
  
    render json: { 
      upvotes: @comment.upvotes, 
      downvotes: @comment.downvotes,
      message: message 
    }, status: :ok
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end
end
