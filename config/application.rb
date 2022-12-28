require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Inwentaryzacja
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Don't generate
    config.generators do |g|
      g.system_tests    nil
      #g.helper          false
      #g.stylesheets     false
      #g.javascripts     false

      # uuid as PK
      g.orm :active_record, primary_key_type: :uuid
      # uuid as FK
      g.orm :active_record, foreign_key_type: :uuid
    end

    config.time_zone = 'Warsaw'

    config.i18n.default_locale = :pl
    config.i18n.available_locales = [:pl, :en]

    #config.active_storage.variant_processor = :vips

    config.middleware.use Rack::Attack

  end
end
