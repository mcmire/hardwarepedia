module Riggifier
  class << self
    def database_settings
      @database_settings ||= YAML.load_file("#{Rails.root}/config/database.mongo.yml")
    end
    def establish_database(env = Rails.env)
      Mongoid.config.database = Mongo::Connection.new.db(database_settings[env.to_s]["database"])
    end
  end
end

Riggifier.establish_database

Riggifier::Application.configure do
  config.generators do |g|
    g.orm :mongoid
  end
end