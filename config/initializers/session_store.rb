# Be sure to restart your server when you modify this file.
#Rails.application.config.session_store :cache_store, key: Rails.application.secrets.cache_store_key

# Add gem 'redis-rails' if session_expires
Rails.application.config.session_store :redis_store, {
  servers: [
    { host: Rails.application.secrets.redis_host, port: 6379, db: 0 },
  ],
  expire_after: 60.minutes,
  key: Rails.application.secrets.cache_store_key
}
