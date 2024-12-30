if Rails.env.development? || Rails.env.test?
  Rswag::Api.configure do |c|


  c.openapi_root = Rails.root.to_s + '/swagger'

  
  end
end