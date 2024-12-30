if defined?(Rswag::Api)
  if Rails.env.development? || Rails.env.test? || Rails.env.production?
    Rswag::Api.configure do |c|
      c.openapi_root = Rails.root.to_s + '/swagger'
    end
  end
end
