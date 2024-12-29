class SessionsController < ApplicationController
  skip_before_action :authorize_request, only: [:create]
  def create
    user = User.find_by(email: params[:email])
    if user.present?
      if user.locked?
        render json: { errors: ["Conta bloqueada. Tente novamente mais tarde."] }, status: :unauthorized
        return
      end

      if user.authenticate(params[:password])
        user.unlock!
        
        token = JsonWebToken.encode({ user_id: user.id })
        session[:user_id] = user.id

        render json: { token: token, message: "Login realizado com sucesso!" }, status: :ok
      else
        user.increment!(:failed_attempts)
        if user.failed_attempts >= 5
          user.lock!
          render json: { errors: ["Conta bloqueada devido a muitas tentativas. Aguarde 30 minutos ou contacte o suporte."] }, status: :unauthorized
        else
          render json: { errors: ["Email ou senha inválidos"] }, status: :unauthorized
        end
      end
    else
      # Se não achar nenhum usuário, não dê detalhes para não vazar informação
      render json: { errors: ["Email ou senha inválidos"] }, status: :unauthorized
    end
  end

  def destroy
    session[:user_id] = nil
    render json: { message: "Logout realizado com sucesso!" }, status: :ok
  end
end
