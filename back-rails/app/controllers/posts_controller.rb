class PostsController < ApplicationController

#exibir todos os posts
    def index
        if params[:query].present?
            @posts = Post.where("title LIKE ? OR content LIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
        else
            @posts = Post.all
        end
    end

    def create
        @post = Post.new(post_params)
        if @post.save
            redirect_to posts_path, notice: "Post criado com sucesso!"
        else
            render :new, alert: "Erro ao criar post!"
        end

    end

    private

    def post_params
        params.require(:post).permit(:title, :content)
        end
    end
