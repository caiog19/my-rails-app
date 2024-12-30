class TranslationsController < ApplicationController
    before_action :set_locale
  
    def show
      render json: translations.to_h
    end
  
    private
  
    def set_locale
      I18n.locale = params[:locale] || I18n.default_locale
    end
  
    def translations
      I18n.backend.send(:translations)[I18n.locale]
    end
  end
  