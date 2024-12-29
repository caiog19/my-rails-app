class Rack::Attack
    # permitir 20 requisições de login por IP a cada 1 minuto
    throttle('req/ip', limit: 20, period: 1.minute) do |req|
      req.ip if req.path == '/login' && req.post?
    end
  
    # banir IPs maliciosos
    blocklist('block 1.2.3.4') do |req|
      req.ip == '1.2.3.4'
    end

  throttle('signup/ip', limit: 5, period: 1.minute) do |req|
    req.ip if req.path == '/users' && req.post?
  end
  
  # Logar quando Rack::Attack bloquear algo
  ActiveSupport::Notifications.subscribe('rack.attack') do |_name, _start, _finish, _request_id, payload|
    req = payload[:request]
    Rails.logger.info "Rack::Attack #{req.ip} foi bloqueado"
  end
end

  