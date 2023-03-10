Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  # BJ 2020.05.31 
    # config.assets.js_compressor = :uglifier
    config.assets.js_compressor = Uglifier.new(harmony: true)
  # END BJ 2020.03.31 
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  config.cache_store = :redis_cache_store, {
    driver: :hiredis, 
    url: Rails.application.secrets.redis_url,     
    connect_timeout: 30,  # Defaults to 20 seconds
    read_timeout:    1.0, # Defaults to 1 second
    write_timeout:   1.0, # Defaults to 1 second
   
    error_handler: -> (method:, returning:, exception:) {
      # Report errors to Sentry as warnings
      Raven.capture_exception exception, level: 'warning',
        tags: { method: method, returning: returning }
    }
  }

  config.action_controller.page_cache_directory = Rails.root.join("public", "cached_pages")

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "registration_#{Rails.env}"

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  # config.i18n.fallbacks = true
  config.i18n.fallbacks = [I18n.default_locale]

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local
  # config.default_url_options = { host: Rails.application.secrets.domain_name }
  #Rails.application.routes.default_url_options[:host] = 'localhost:3000'
  Rails.application.routes.default_url_options = { host: Rails.application.secrets.domain_name }



  config.action_mailer.smtp_settings = {
    address: Rails.application.secrets.email_provider_address,
    port: Rails.application.secrets.email_provider_port,
    domain: Rails.application.secrets.domain_name,
#    user_name: Rails.application.secrets.email_provider_username,
#    password: Rails.application.secrets.email_provider_password
#    authentication: "plain",
    openssl_verify_mode: 'none',
    enable_starttls_auto: false
  }
  # ActionMailer Config
  config.action_mailer.default_url_options = { :host => Rails.application.secrets.domain_name }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false

end
