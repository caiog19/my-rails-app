class UserMailer < ApplicationMailer
  def password_reset(reset_link)
    @user = params[:user]
    @reset_link = reset_link
    mail(to: @user.email, subject: 'Instruções para recuperação de senha') do |format|
      format.html { render 'password_reset' }
      format.text { render 'password_reset' }
    end
  end
end
