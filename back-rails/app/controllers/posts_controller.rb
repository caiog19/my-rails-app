class PostsController < ApplicationController
  before_action :authorize_request, except: [:index]
  before_action :set_post, only: [:update, :destroy]

  # Exibir todos os posts (Home)
  def index
    if params[:query].present?
      query = "%#{params[:query]}%"
      @posts = Post.joins(:user)
                   .includes(:tags)
                   .select('posts.*, users.full_name as user_full_name')
                   .where("posts.title LIKE :query OR posts.content LIKE :query", query: query)
                   .order(created_at: :desc)
    else
      @posts = Post.joins(:user)
                   .includes(:tags)
                   .select('posts.*, users.full_name as user_full_name')
                   .order(created_at: :desc)
    end
    @posts = @posts.page(params[:page]).per(3)
    render json: {
      posts: @posts.as_json(include: { tags: { only: [:id, :name] } }),
      meta: {
        current_page: @posts.current_page,
        total_pages: @posts.total_pages,
        total_count: @posts.total_count
      }
    }
  end

  # Meus Posts (do usuário autenticado)
  def meus_posts
    @posts = Post.where(user_id: @current_user.id).includes(:tags).order(created_at: :desc)
    @posts = @posts.page(params[:page]).per(3)
    render json: {
      posts: @posts.as_json(include: :tags),
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
      render json: @post.as_json(include: :tags), status: :created
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

#agora com tags

  # Atualizar um post existente
  def update
    if @current_user.admin? || @post.user_id == @current_user.id
      if @post.update(post_params)
        render json: { message: "Post atualizado", post: @post.as_json(include: :tags) }, status: :ok
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: ["Você não tem permissão para editar este post."] }, status: :forbidden
    end
  end

  # Excluir um post

  def destroy
    if @current_user.admin? || @post.user_id == @current_user.id
      if @post.destroy
        render json: { message: 'Post excluído com sucesso' }, status: :ok
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
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

  def authorize_admin_or_owner
    unless current_user.admin? || @post.user_id == current_user.id
      render json: { error: "Você não tem permissão para realizar esta ação." }, status: :forbidden
    end
  end

  def set_post
    @post = Post.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Post não encontrado' }, status: :not_found
  end

  def post_params
    params.require(:post).permit(:title, :content, tag_ids: [])
  end

  def post_with_tags
    @post.as_json(include: :tags)
  end
end
