class AuthController < ApplicationController
  before_action :authorize_request

  def me
    render json: { user: @current_user }, status: :ok
  end

  def update_profile
    if @current_user.update(user_params)
      render json: { message: 'Perfil atualizado com sucesso!', user: @current_user }, status: :ok
    else
      render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :email, :password, :password_confirmation)
  end
end
