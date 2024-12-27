class CommentsController < ApplicationController
    def create
        @post = Post.find(params[:post_id])
        @comment = @post.comments.build(comment_params)
        @comment.user = current_user if @current_user

        if @comment.save
            render json: @comment, status: :created
        else
            render json: { erros: @comment.errors.full_messages }, status: :unprocessable_entity
        end
    end

    private

    def comment_params
        params.require(:comment).permit(:content)
    end
end