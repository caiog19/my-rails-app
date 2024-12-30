class FileUploadsController < ApplicationController
    before_action :authorize_request
  
    def create
      if params[:file].blank?
        return render json: { error: 'Nenhum arquivo enviado' }, status: :unprocessable_entity
      end
  
      resource_type = params[:resource_type]
      unless %w[posts tags].include?(resource_type)
        return render json: { error: 'Tipo de recurso inválido (use "posts" ou "tags")' }, status: :unprocessable_entity
      end
  
      file_path = Rails.root.join('tmp', params[:file].original_filename)
      File.open(file_path, 'wb') { |f| f.write(params[:file].read) }
  
      BulkUploadWorker.perform_async(file_path.to_s, @current_user.id, resource_type)
  
      render json: { message: 'Arquivo recebido. O processamento será feito em segundo plano.' }, status: :ok
    end
  end