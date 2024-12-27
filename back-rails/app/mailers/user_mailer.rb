class UserMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  def password_reset(reset_token)
    @user = params[:user]         
    @reset_token = reset_token

    mail(to: @user.email, subject: 'Instruções para recuperação de senha') do |format|
      format.html { render 'password_reset' }
      format.text { render 'password_reset' }
    end
  end
end
