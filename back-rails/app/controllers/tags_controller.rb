class TagsController < ApplicationController
  before_action :authorize_request
  before_action :set_tag, only: [:destroy]

  def index
    @tags = Tag.order(:name)
    render json: @tags
  end

  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      render json: @tag, status: :created
    else
      render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def destroy
    if @tag.destroy
      render json: { message: 'Tag deletada com sucesso.' }, status: :ok
    else
      render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_tag
    @tag = Tag.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Tag não encontrada.' }, status: :not_found
  end

  def tag_params
    params.require(:tag).permit(:name)
  end

end
