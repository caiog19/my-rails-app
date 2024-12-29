class ApplicationController < ActionController::API
  before_action :authorize_request
  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale] || extract_locale_from_header || I18n.default_locale
  end

  private

  def extract_locale_from_header
    request.env['HTTP_ACCEPT_LANGUAGE']&.scan(/^[a-z]{2}/)&.first&.to_sym
  end

  def authorize_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    begin
      decoded = JsonWebToken.decode(token)
      @current_user = User.find(decoded[:user_id])
    rescue JWT::DecodeError, NoMethodError
      render json: { errors: I18n.t('errors.token_invalid_or_absent') }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { errors: I18n.t('errors.user_not_found') }, status: :unauthorized
    end
  end

  def authorize_admin
    render json: { errors: I18n.t('errors.access_denied') }, status: :forbidden unless @current_user&.admin?
  end
end
