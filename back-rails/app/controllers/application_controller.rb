class ApplicationController < ActionController::API
  before_action :authorize_request

  private

  def authorize_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    begin
      decoded = JsonWebToken.decode(token)
      @current_user = User.find(decoded[:user_id])
    rescue JWT::DecodeError, NoMethodError
      render json: { errors: "Token inválido ou ausente" }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { errors: "Usuário não encontrado" }, status: :unauthorized
    end
  end
end
