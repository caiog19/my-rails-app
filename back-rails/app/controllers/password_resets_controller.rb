class PasswordResetsController < ApplicationController
  skip_before_action :authorize_request

  def create
    unless params[:email] =~ URI::MailTo::EMAIL_REGEXP
      return render json: { errors: ["Formato de email inválido"] }, status: :unprocessable_entity
    end
  
    user = User.find_by(email: params[:email].to_s.strip.downcase)
    if user
      user.generate_reset_token!
      begin
        frontend_url = Rails.application.credentials.frontend[:url] || 'https://my-rails-app.vercel.app'
        reset_link = "#{frontend_url}/password_resets/#{user.reset_password_token}"
        UserMailer.with(user: user).password_reset(reset_link).deliver_now
      rescue StandardError => e
        Rails.logger.error("Erro ao enviar email: #{e.message}")
        return render json: { errors: ["Erro ao enviar o email. Tente novamente mais tarde."] }, status: :internal_server_error
      end
    end
    # Responde para o frontend que, se o email existir, as instruções foram enviadas
    render json: { message: "Se o email existir, as instruções serão enviadas." }, status: :ok
  end
  

  def edit
    user = User.find_by(reset_password_token: params[:id].to_s.strip)
  
    if user.nil? || user.reset_password_sent_at.nil? || user.reset_password_sent_at <= 2.hours.ago
      render json: { errors: ["Token inválido ou expirado"] }, status: :unprocessable_entity
    else
      render json: { message: "Token válido", token: params[:id] }, status: :ok
    end
  end
  
  
  def update
    user = User.find_by(reset_password_token: params[:token].to_s.strip)
  
    if user.nil? || user.reset_password_sent_at.nil? || user.reset_password_sent_at <= 2.hours.ago
      return render json: { errors: ["Token inválido ou expirado"] }, status: :unprocessable_entity
    end
  
    if user.update(password_params)
      user.update(reset_password_token: nil) 
      render json: { message: "Senha atualizada com sucesso!" }, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  

  private

  def password_params
    params.permit(:password, :password_confirmation)
  end
  
end
