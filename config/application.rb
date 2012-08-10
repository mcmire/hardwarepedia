
require File.expand_path('../boot', __FILE__)

require 'pp'
require 'rails'

groups = Rails.groups(:assets => %w(development test))
Bundler.setup(*groups)
require 'action_controller/railtie'
require 'action_view/railtie'
Bundler.require(*groups)

# necessary?
Logging.logger['Base'].level = :debug

module Hardwarepedia
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add presenters to the load path
    config.autoload_paths << Rails.root.join('app/presenters')

    # Rails 3 no longer autoloads lib/.
    # See: <https://rails.lighthouseapp.com/projects/8994/tickets/5218-rails-3-rc-does-not-autoload-from-lib#ticket-5218-8>
    config.autoload_paths << Rails.root.join('lib')

    # Set Time.zone default to the specified zone and make Active Record
    # auto-convert to this zone. Run "rake -D time" for a list of tasks for
    # finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enforce whitelist mode for mass assignment. This will create an empty
    # whitelist of attributes available for mass-assignment for all models in
    # your app. As such, your models will need to explicitly whitelist or
    # blacklist accessible parameters by using an attr_accessible or
    # attr_protected declaration.
    # config.active_record.whitelist_attributes = false

    # Enable the asset pipeline
    config.assets.enabled = true
    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # config.cache_store = [:file_store, Rails.root.join('tmp/cache'), :expires_in => 1.day]

    config.show_log_configuration = false

    config.after_initialize do
      Hardwarepedia.init
    end
  end
end
