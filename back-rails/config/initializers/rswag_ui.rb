if Rails.env.development? || Rails.env.test?
  Rswag::Ui.configure do |c|

 
  c.openapi_endpoint '/api-docs/swagger/v1/swagger.yaml', 'API V1 Docs'
  c.basic_auth_enabled = true
  c.basic_auth_credentials 'admin', 'password'
  
  end
end
