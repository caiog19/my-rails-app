class BulkUploadWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5  # Número de tentativas em caso de falha

  def perform(file_path, user_id, resource_type)
    Rails.logger.info "Processando arquivo: #{file_path} para resource_type: #{resource_type}, user_id: #{user_id || 'nenhum'}"

    # Validação de usuário para posts (não necessária para tags)
    if resource_type == 'posts'
      user = User.find_by(id: user_id)
      unless user
        Rails.logger.error "Usuário com ID #{user_id} não encontrado."
        return
      end
    end

    unless File.exist?(file_path)
      Rails.logger.error "Arquivo não encontrado: #{file_path}"
      return
    end

    process_file(file_path, user_id, resource_type)
    File.delete(file_path) if File.exist?(file_path)
    Rails.logger.info "Processamento do arquivo #{file_path} concluído e deletado."
  end

  private

  def process_file(file_path, user_id, resource_type)
    case resource_type
    when 'posts'
      process_posts(file_path, user_id)
    when 'tags'
      process_tags(file_path)
    else
      Rails.logger.warn "Tipo de recurso desconhecido: #{resource_type}"
    end
  end

  def process_posts(file_path, user_id)
    current_title = nil
    File.foreach(file_path).with_index do |line, index|
      next if line.strip.empty?

      if line.start_with?('t=')
        current_title = line[2..].strip
      elsif line.start_with?('c=') && current_title
        begin
          content = line[2..].strip
          Post.create!(
            title: current_title,
            content: content,
            user_id: user_id
          )
          Rails.logger.info "Post criado: #{current_title}"
          current_title = nil
        rescue => e
          Rails.logger.error "Erro ao criar post na linha #{index + 1}: #{e.message}"
        end
      else
        Rails.logger.warn "Formato inesperado na linha #{index + 1}: #{line.strip}"
      end
    end
  end

  def process_tags(file_path)
    File.foreach(file_path).with_index do |line, index|
      next if line.strip.empty?

      begin
        tag_name = line.strip
        tag = Tag.find_or_create_by!(name: tag_name)
        Rails.logger.info "Tag criada ou encontrada: #{tag.name}"
      rescue => e
        Rails.logger.error "Erro ao criar tag na linha #{index + 1}: #{e.message}"
      end
    end
  end
end
class BulkUploadWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5  # Número de tentativas em caso de falha

  def perform(file_path, user_id, resource_type)
    Rails.logger.info "Processando arquivo: #{file_path} para resource_type: #{resource_type}, user_id: #{user_id || 'nenhum'}"

    # Validação de usuário para posts (não necessária para tags)
    if resource_type == 'posts'
      user = User.find_by(id: user_id)
      unless user
        Rails.logger.error "Usuário com ID #{user_id} não encontrado."
        return
      end
    end

    unless File.exist?(file_path)
      Rails.logger.error "Arquivo não encontrado: #{file_path}"
      return
    end

    process_file(file_path, user_id, resource_type)
    File.delete(file_path) if File.exist?(file_path)
    Rails.logger.info "Processamento do arquivo #{file_path} concluído e deletado."
  end

  private

  def process_file(file_path, user_id, resource_type)
    case resource_type
    when 'posts'
      process_posts(file_path, user_id)
    when 'tags'
      process_tags(file_path)
    else
      Rails.logger.warn "Tipo de recurso desconhecido: #{resource_type}"
    end
  end

  def process_posts(file_path, user_id)
    current_title = nil
    File.foreach(file_path).with_index do |line, index|
      next if line.strip.empty?

      if line.start_with?('t=')
        current_title = line[2..].strip
      elsif line.start_with?('c=') && current_title
        begin
          content = line[2..].strip
          Post.create!(
            title: current_title,
            content: content,
            user_id: user_id
          )
          Rails.logger.info "Post criado: #{current_title}"
          current_title = nil
        rescue => e
          Rails.logger.error "Erro ao criar post na linha #{index + 1}: #{e.message}"
        end
      else
        Rails.logger.warn "Formato inesperado na linha #{index + 1}: #{line.strip}"
      end
    end
  end

  def process_tags(file_path)
    File.foreach(file_path).with_index do |line, index|
      next if line.strip.empty?

      begin
        tag_name = line.strip
        tag = Tag.find_or_create_by!(name: tag_name)
        Rails.logger.info "Tag criada ou encontrada: #{tag.name}"
      rescue => e
        Rails.logger.error "Erro ao criar tag na linha #{index + 1}: #{e.message}"
      end
    end
  end
end
