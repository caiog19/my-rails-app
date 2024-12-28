class PostsController < ApplicationController
  before_action :authorize_request, except: [:index]
  before_action :set_post, only: [:update, :destroy]

  # Exibir todos os posts (Home)
  def index
    if params[:query].present?
      query = "%#{params[:query]}%"
      @posts = Post.where("title LIKE :query OR content LIKE :query", query: query)
    else
      @posts = Post.order(created_at: :desc)
    end
    @posts = @posts.page(params[:page]).per(3)
    render json: {
      posts: @posts,
      meta: {
        current_page: @posts.current_page,
        total_pages: @posts.total_pages,
        total_count: @posts.total_count
      }
    }, status: :ok
  end

  # Meus Posts (do usuário autenticado)
  def meus_posts
    @posts = Post.where(user_id: @current_user.id).order(created_at: :desc)
    @posts = @posts.page(params[:page]).per(3)
    render json: {
      posts: @posts,
      meta: {
        current_page: @posts.current_page,
        total_pages: @posts.total_pages,
        total_count: @posts.total_count
      }
    }
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

  private
  # Permitir exclusão apenas se o usuário for admin ou autor do post
  def authorize_destroy_post
    post = Post.find(params[:id])
    unless @current_user.admin? || post.user_id == @current_user.id
      render json: { errors: "Você não tem permissão para excluir este post" }, status: :forbidden
    end
  end

  def set_post
    @post = Post.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Post não encontrado' }, status: :not_found
  end

  def post_params
    params.require(:post).permit(:title, :content)
  end
end
