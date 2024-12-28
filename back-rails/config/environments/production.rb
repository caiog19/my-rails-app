require "active_support/core_ext/integer/time"

Rails.application.configure do
  
  config.action_mailer.smtp_settings = {
    user_name: 'apikey', 
    password: ENV['SENDGRID_API_KEY'],
    domain: 'my-rails-app.vercel.app', 
    address: 'smtp.sendgrid.net',
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true
  }

  # URL padrão para links no email
  config.action_mailer.default_url_options = { host: 'my-rails-app.vercel.app', protocol: 'https' }
  
  # Garante que erros de entrega de email serão levantados
  config.action_mailer.raise_delivery_errors = true

  # Realiza envios de emails no ambiente de produção
  config.action_mailer.perform_deliveries = true

  # Não realiza caching de emails
  config.action_mailer.perform_caching = false

  # Força SSL para todas as conexões
  config.force_ssl = true

  # Carrega classes antecipadamente
  config.eager_load = true

  # Considera as requisições como não locais (para exibir páginas de erro em produção)
  config.consider_all_requests_local = false

  # Configura o armazenamento ativo para produção
  config.active_storage.service = :local 

  # Configurações de cache
  config.cache_classes = true
  config.action_controller.perform_caching = true
  config.cache_store = :memory_store
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Minimiza logs de depreciação
  config.active_support.deprecation = :notify

  # Configura logs para ambiente de produção
  config.log_level = :info
  config.log_tags = [:request_id]

  # Configura o logger para o STDOUT em produção
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Configurações de ActiveRecord
  config.active_record.dump_schema_after_migration = false
  config.active_record.verbose_query_logs = false
end
