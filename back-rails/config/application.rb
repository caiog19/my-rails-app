require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module BackRails
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_paths << Rails.root.join('app/lib')
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :pt]
    config.autoload_lib(ignore: %w[assets tasks])
    config.middleware.use Rack::Attack
  end
end

