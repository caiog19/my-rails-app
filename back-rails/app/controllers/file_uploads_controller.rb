class FileUploadsController < ApplicationController
  before_action :authorize_request

  def create
    Rails.logger.info "Iniciando o upload de arquivo."

    if params[:file].blank?
      Rails.logger.warn "Nenhum arquivo foi enviado."
      return render json: { error: 'Nenhum arquivo enviado' }, status: :unprocessable_entity
    end

    resource_type = params[:resource_type]
    unless %w[posts tags].include?(resource_type)
      Rails.logger.warn "Tipo de recurso inválido: #{resource_type}"
      return render json: { error: 'Tipo de recurso inválido (use "posts" ou "tags")' }, status: :unprocessable_entity
    end

    # Geração de um nome de arquivo único para evitar colisões
    unique_filename = "#{SecureRandom.uuid}_#{params[:file].original_filename}"
    file_path = Rails.root.join('tmp', unique_filename)
    File.open(file_path, 'wb') { |f| f.write(params[:file].read) }
    Rails.logger.info "Arquivo salvo em: #{file_path}"

    # Determinar o user_id dinamicamente (pode ser @current_user ou nil para recursos públicos)
    user_id = resource_type == 'tags' ? nil : @current_user.id

    # Enfileirar o worker
    BulkUploadWorker.perform_async(file_path.to_s, user_id, resource_type)
    Rails.logger.info "Job BulkUploadWorker enfileirado com file_path: #{file_path}, user_id: #{user_id}, resource_type: #{resource_type}"

    render json: { message: 'Arquivo recebido. O processamento será feito em segundo plano.' }, status: :ok
  rescue => e
    Rails.logger.error "Erro ao processar upload de arquivo: #{e.message}"
    render json: { error: 'Erro interno do servidor.' }, status: :internal_server_error
  end
end
