class UsersController < ApplicationController
  skip_before_action :authorize_request, only: [:create]
  def create
    @user = User.new(user_params)
    if @user.save
      token = JsonWebToken.encode({ user_id: @user.id }) 
      render json: { token: token, message: "Usuário cadastrado com sucesso!" }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
