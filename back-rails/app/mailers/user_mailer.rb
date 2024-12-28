class UserMailer < ApplicationMailer
  def password_reset(reset_token)
    @user = params[:user]
    frontend_url = Rails.application.credentials.frontend[:url].chomp('/')
    @reset_link = "#{frontend_url}/password_resets/#{reset_token}"

    mail(to: @user.email, subject: 'Instruções para recuperação de senha') do |format|
      format.html { render 'password_reset' }
      format.text { render 'password_reset' }
    end
  end
end
