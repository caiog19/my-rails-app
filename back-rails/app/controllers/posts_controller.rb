class PostsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create]

    # Exibir todos os posts
    def index
      if params[:query].present?
        @posts = Post.where("title LIKE ? OR content LIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
      else
        @posts = Post.all
      end
      render json: @posts 
    end
  
    def create
      @post = Post.new(post_params)
      if @post.save
        render json: @post, status: :created 
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity 
      end
    end
    
  
    private
  
    def post_params
      params.require(:post).permit(:title, :content)
    end
  end
  