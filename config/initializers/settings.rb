require 'yaml'

module Hardwarepedia
  class << self
    # adapted from http://sickpea.com/2009/6/rails-app-configuration-in-10-lines
    def settings(env = Rails.env)
      @settings ||= YAML.load(ERB.new(File.read(Rails.root.join("config/settings.yml"))).result)
      HashWithIndifferentAccess.new(@settings[env.to_s]).freeze
    end
    alias_method :config, :settings
    def [](key)
      settings[key]
    end
    def common_settings
      settings("common")
    end
    alias_method :common_config, :common_settings
  end
end