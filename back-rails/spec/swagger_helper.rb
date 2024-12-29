require 'rails_helper'

RSpec.configure do |config|

  config.openapi_root = Rails.root.join('swagger').to_s


  config.openapi_specs = {
    'swagger/v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      servers: [
        {
          url: 'https://my-rails-app-r7us.onrender.com',
          description: 'Servidor de Produção'
        },
        {
          url: 'http://localhost:3000',
          description: 'Servidor Local'
        }
      ]
    }
  }

  config.openapi_format = :yaml
end
