class PostsController < ApplicationController
  before_action :authorize_request, except: [:index]
  before_action :set_post, only: [:update, :destroy]

  # Exibir todos os posts
  def index
    if params[:query].present?
      query = "%#{params[:query]}%"
      @posts = Post.where("title LIKE :query OR content LIKE :query", query: query)
    else
      @posts = Post.order(created_at: :desc)
    end
    @posts = @posts.page(params[:page]).per(3)
    render json: @posts
  end

  # Criar um novo post
  def create
    @post = Post.new(post_params)
    @post.user_id = @current_user.id
    if @post.save
      render json: @post, status: :created
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Atualizar um post existente
  def update
    if @post.user_id == @current_user.id
      if @post.update(post_params)
        render json: @post, status: :ok
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Você não tem permissão para editar este post' }, status: :forbidden
    end
  end

  # Excluir um post
  def destroy
    if @post.user_id == @current_user.id
      @post.destroy
      render json: { message: 'Post excluído com sucesso' }, status: :ok
    else
      render json: { error: 'Você não tem permissão para excluir este post' }, status: :forbidden
    end
  end

  def meus_posts
    @posts = Post.where(user_id: @current_user.id).order(created_at: :desc)
    render json: @posts, status: :ok
  end

  private

  def set_post
    @post = Post.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Post não encontrado' }, status: :not_found
  end

  def post_params
    params.require(:post).permit(:title, :content)
  end
end
