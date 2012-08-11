
config = Hardwarepedia::Application.config

config.sequel.truncate_sql_to = 500

config.after_initialize do
  Logging.logger['Sequel'].additive = false
  Logging.logger['Sequel'].add_appenders('file')
end
