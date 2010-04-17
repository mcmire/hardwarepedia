Mongoid.configure do |config|
  settings = YAML.load_file('config/database.mongo.yml')[Rails.env]
  name = settings["database"]
  config.master = Mongo::Connection.new.db(name)
end