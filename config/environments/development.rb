Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.page_cache_directory = Rails.root.join("public", "cached_pages")

    # config.cache_store = :memory_store
    #config.cache_store = :redis_store, Rails.application.secrets.redis_url

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


    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local
  # config.default_url_options = { host: Rails.application.secrets.domain_name }
  #Rails.application.routes.default_url_options[:host] = 'localhost:3000'
  Rails.application.routes.default_url_options = { host: Rails.application.secrets.domain_name }



  config.action_mailer.smtp_settings = {
    address: Rails.application.secrets.email_provider_address,
    port: Rails.application.secrets.email_provider_port,
    domain: Rails.application.secrets.domain_name,
    user_name: Rails.application.secrets.email_provider_username,
    password: Rails.application.secrets.email_provider_password,
    authentication: "plain",
    openssl_verify_mode: 'none',
    enable_starttls_auto: true
  }

  #config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_mailer.default_url_options = { :host => Rails.application.secrets.domain_name }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true
  # Send email in development mode?
  config.action_mailer.perform_deliveries = true

end
