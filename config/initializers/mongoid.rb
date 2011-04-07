module ProjectXenon
  class << self
    def database_settings
      @database_settings ||= YAML.load_file("#{Rails.root}/config/database.mongo.yml")
    end
    def establish_database(env = Rails.env)
      Mongoid.config.database = Mongo::Connection.new.db(database_settings[env.to_s]["database"])
    end
  end
end

ProjectXenon.establish_database

ProjectXenon::Application.configure do
  config.generators do |g|
    g.orm :mongoid
  end
end