module DatabasePreparation
  module DatabaseAdapters
    module ActiveRecord
      def database_settings
        @database_settings ||= ::ActiveRecord::Base.configurations
      end

      def establish_database(env = Rails.env)
        ::ActiveRecord::Base.establish_connection(env)
      end
      
      def all_collections
        ::ActiveRecord::Base.connection.tables - ["schema_migrations"]
      end
      
      def plow_collection(name)
        ::ActiveRecord::Base.connection.execute("TRUNCATE TABLE `#{name}`")
      end
    end
    
    module Mongoid
      def database_settings
        @database_settings ||= ::YAML.load_file("#{Rails.root}/config/database.mongo.yml")
      end

      def establish_database(env = Rails.env)
        ::Mongoid.config.database = ::Mongo::Connection.new.db(database_settings[env.to_s]["database"])
      end
      
      def all_collections
        ::Mongoid.database.collection_names - ["system.indexes"]
      end
      
      def plow_collection(name)
        ::Mongoid.database.plow_collection(name)
      end
    end
  end
  
  module WebFrameworks
    module Rails
      def self.project_root
        Rails.root
      end
      
      def self.current_environment
        Rails.env.to_s
      end
    end
    
    module Padrino
      def self.project_root
        Padrino.root
      end
      
      def self.current_environment
        PADRINO_ENV
      end
    end
  end
  
  def seeds
    (Dir["#{project_root}/data/*"] + Dir["#{project_root}/data/#{current_environment}/*"]).map do |filename|
      collection_name = ::File.basename(filename).sub(/\.([^.]+)$/, "")
      extension = filename.match(/\.([^.]+)$/i)[1].downcase
      model = collection_name.classify.constantize
      [filename, extension, collection_name, model]
    end
  end
  
  LEVELS = [:none, :info, :debug]
  
  def seed_database(options={})
    level = LEVELS.index(options[:level] || :debug)
    options.reverse_merge!(:env => current_environment)
    puts "Seeding the #{options[:env]} database..." if level > 0
    establish_database(options[:env])
    seeds.each do |filename, ext, collection_name, model|
      if ext == "rb"
        records = eval(::File.read(filename))
        puts " - Adding data for #{collection_name}..." if level > 1
        insert_rows(records, model)
      elsif ext == "yml" || ext == "yaml"
        data = ::YAML.load_file(filename)
        table = (Hash === data) ? data[data.keys.first] : data
        puts " - Adding data for #{collection_name}..." if level > 1
        insert_rows(records, model)
      else
        lines = ::File.read(filename).split(/\n/)
        puts " - Adding data for #{collection_name}..." if level > 1
        insert_rows_from_csv(lines, model)
      end
    end
  end
  
  def plow_database(options={})
    level = LEVELS.index(options[:level] || :debug)
    options.reverse_merge!(:env => current_environment)
    puts "Plowing the #{options[:env]} database..." if level > 0
    establish_database(options[:env])
    collections = options[:all] ? all_collections : seedable_collections
    collections.each do |coll|
      plow_collection(coll)
      puts " - Plowed #{coll}" if level > 1
    end
  end
  
  def seedable_collections
    seeds.map {|filename, ext, collection_name, model| collection_name }
  end
  
private
  def insert_rows(rows, model)
    rows.each {|row| model.create!(row) }
  end
  
  def insert_rows_from_csv(lines, model)
    columns = lines.shift.sub(/^#[ ]*/, "").split(/,[ ]*/)
    rows = lines.map do |line|
      values = line.split(/\t|[ ]{2,}/).map {|v| v =~ /^null$/i ? nil : v }
      zip = columns.zip(values).flatten
      Hash[*zip]
    end
    insert_rows(rows, model)
  end
end