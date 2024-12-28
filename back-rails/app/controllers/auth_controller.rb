class AuthController < ApplicationController
    before_action :authorize_request
  
    def me
      render json: { user: @current_user }, status: :ok
    end
  end
  