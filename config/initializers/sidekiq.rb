
config = Hardwarepedia::Application.config

# Cause everything in lib/ to be required when Rails.application.eager_load!
# is called. Sidekiq will call this when launching itself.
config.eager_load_paths += [ Rails.root.join('lib').to_s ]

Sidekiq.configure_server do |config|
  #config.redis = Hwp.config.redis
end
