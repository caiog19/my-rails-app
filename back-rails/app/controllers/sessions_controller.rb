class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      render json: { message: "Login realizado com sucesso!" }, status: :ok
    else
      render json: { errors: ["Email ou senha inválidos"] }, status: :unauthorized
    end
  end

  def destroy
    session[:user_id] = nil
    render json: { message: "Logout realizado com sucesso!" }, status: :ok
  end
end
