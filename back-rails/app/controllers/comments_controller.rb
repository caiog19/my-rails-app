class CommentsController < ApplicationController
    before_action :authorize_request, only: [:create], if: -> { request.headers['Authorization'].present? }
    before_action :set_post
  
    # Listar comentários de um post
    def index
      comments = @post.comments.includes(:user).order(created_at: :desc)
      render json: comments.map { |comment|
        {
          id: comment.id,
          content: comment.content,
          author_name: comment.author_name,
          created_at: comment.created_at
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
  
    private
  
    def set_post
      @post = Post.find(params[:post_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Post não encontrado" }, status: :not_found
    end
  
    def comment_params
      params.require(:comment).permit(:content)
    end
  end
  