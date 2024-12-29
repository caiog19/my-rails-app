# app/controllers/auth_controller.rb
class AuthController < ApplicationController
  before_action :authorize_request

  def me
    render json: { user: @current_user }, status: :ok
  end

  def update_profile
    user = @current_user
    errors = []

    # Se veio full_name para atualizar
    if user_params[:full_name].present?
      unless user.authenticate(user_params[:current_password])
        errors << "Senha atual para atualizar o nome está incorreta."
      end

      user.full_name = user_params[:full_name]
    end

    # Se veio email para atualizar
    if user_params[:email].present?
      unless user.authenticate(user_params[:current_password])
        errors << "Senha atual para atualizar o email está incorreta."
      end

      user.email = user_params[:email]
    end

    # Se veio password para atualizar
    if user_params[:password].present?
      unless user.authenticate(user_params[:current_password])
        errors << "Senha atual para atualizar a senha está incorreta."
      end

      user.password = user_params[:password]
      user.password_confirmation = user_params[:password_confirmation]
    end

    if errors.empty?
      if user.save
        render json: { message: 'Perfil atualizado com sucesso.', user: user }, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :full_name,
      :email,
      :password,
      :password_confirmation,
      :current_password
    )
  end
end
