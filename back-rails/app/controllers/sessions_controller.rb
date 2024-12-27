class SessionsController < ApplicationController
  skip_before_action :authorize_request, only: [:create]
  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode({ user_id: user.id }) 
      session[:user_id] = user.id
      render json: { token: token, message: "Login realizado com sucesso!" }, status: :ok
    else
      render json: { errors: ["Email ou senha inválidos"] }, status: :unauthorized
    end
  end

  def destroy
    session[:user_id] = nil
    render json: { message: "Logout realizado com sucesso!" }, status: :ok
  end
end
