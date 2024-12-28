class UsersController < ApplicationController
  skip_before_action :authorize_request, only: [:create]

  def create
    @user = User.new(user_params)

    if @user.save
      token = JsonWebToken.encode({ user_id: @user.id })
      render json: { token: token, message: "Usuário cadastrado com sucesso!" }, status: :created
    else
      render json: { errors: format_errors(@user.errors) }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :full_name)
  end

  def format_errors(errors)
    errors.details.map do |field, details|
      details.map do |error_detail|
        {
          field: field,
          message: errors.full_message(field, error_detail[:error])
        }
      end
    end.flatten
  end
end
