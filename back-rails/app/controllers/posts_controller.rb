class PostsController < ApplicationController
  before_action :authenticate_optional, only: [:index]
  before_action :authorize_request, except: [:index]
  before_action :set_post, only: [:update, :destroy]
  
  def authenticate_optional
    if request.headers['Authorization'].present?
      authorize_request
    else
      @current_user = nil
    end
  end

  # Exibir todos os posts (Home)
  def index
    if params[:query].present?
      query = params[:query]
      @posts = Post.joins(:user)
                   .includes(:tags, comments: [:user, :votes]) 
                   .select('posts.*, users.full_name as user_full_name')
                   .where("posts.title ILIKE :query OR posts.content ILIKE :query OR tags.name ILIKE :query", query: "%#{query}%")
                   .references(:tags)
                   .order(Arel.sql("similarity(posts.title, '#{query}') DESC"))
    else
      @posts = Post.joins(:user)
                   .includes(:tags, comments: [:user, :votes]) 
                   .select('posts.*, users.full_name as user_full_name')
                   .order(created_at: :desc)
    end
    @posts = @posts.page(params[:page]).per(3)

    # Processa os comentários com base na autorização
    processed_posts = @posts.map do |post|
      post_hash = post.as_json(include: { tags: { only: [:id, :name] } })
      
      # Processa cada comentário
      comments = post.comments.map do |comment|
        if comment.hidden && !(@current_user&.admin?)
          {
            id: comment.id,
            content: "Este comentário está oculto.",
            author_name: comment.author_name,
            created_at: comment.created_at,
            hidden: comment.hidden,
            upvotes: comment.upvotes,
            downvotes: comment.downvotes,
            current_user_vote: @current_user ? comment.votes.find_by(user: @current_user)&.vote_type : nil
          }
        else
          {
            id: comment.id,
            content: comment.content,
            author_name: comment.author_name,
            created_at: comment.created_at,
            hidden: comment.hidden,
            upvotes: comment.upvotes,
            downvotes: comment.downvotes,
            current_user_vote: @current_user ? comment.votes.find_by(user: @current_user)&.vote_type : nil
          }
        end
      end
      post_hash['comments'] = comments
      post_hash
    end

    render json: {
      posts: processed_posts,
      meta: {
        current_page: @posts.current_page,
        total_pages: @posts.total_pages,
        total_count: @posts.total_count
      }
    }
  end
  
  # Meus Posts (do usuário autenticado)
  def meus_posts
    @posts = Post.where(user_id: @current_user.id)
                 .includes(:tags, comments: :user) 
                 .order(created_at: :desc)
    @posts = @posts.page(params[:page]).per(3)
    render json: {
      posts: @posts.as_json(
        include: {
          tags: { only: [:id, :name] },
          comments: { 
            include: { user: { only: [:full_name] } },
            methods: :author_name,
            only: [:id, :content, :created_at]
          }
        }
      ),
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

  # Atualizar um post existente
  def update
    if @current_user.admin? || @post.user_id == @current_user.id
      if @post.update(post_params)
        render json: { message: I18n.t('posts.updated'), post: @post.as_json(include: :tags) }, status: :ok
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: [I18n.t('errors.no_permission_to_edit_post')] }, status: :forbidden
    end
  end

  # Excluir um post
  def destroy
    if @current_user.admin? || @post.user_id == @current_user.id
      if @post.destroy
        render json: { message: I18n.t('posts.deleted') }, status: :ok
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: I18n.t('errors.no_permission_to_delete_post') }, status: :forbidden
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
    render json: { error: I18n.t('posts.not_found') }, status: :not_found
  end

  def post_params
    params.require(:post).permit(:title, :content, tag_ids: [])
  end

  def post_with_tags
    @post.as_json(include: :tags)
  end
end
