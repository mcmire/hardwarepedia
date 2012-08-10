
# Cause everything in lib/ to be required when Rails.application.eager_load!
# is called. Sidekiq will call this when launching itself.
config.eager_load_paths << Rails.root.join('lib')

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Hardwarepedia::Sidekiq::RedisConnectionPool
  end
end
