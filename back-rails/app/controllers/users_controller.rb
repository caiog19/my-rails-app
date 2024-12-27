class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  def create
    puts "Recebido params: #{params.inspect}"
    @user = User.new(user_params)
    if @user.save
      render json: { message: "Usuário cadastrado com sucesso!" }, status: :created
    else
      puts "Erros de validação: #{@user.errors.full_messages}"
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end


  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
