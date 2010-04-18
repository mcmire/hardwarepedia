module DatabaseSeeding
  def seeds
    Dir["#{Rails.root}/data/*"].map do |filename|
      collection_name = File.basename(filename).sub(/\.([^.]+)$/, "")
      extension = filename.match(/\.([^.]+)$/i)[1].downcase
      model = table_name.classify.constantize
      [filename, extension, collection_name, model]
    end
  end
  
  def seeded_collections
    seeds.map {|filename, ext, collection_name, model| Mongoid.database.collection(collection_name) }
  end
  
  def seed_database(options={})
    options.reverse_merge!(:env => Rails.env)
    puts "Seeding the #{options[:env]} database..."
    establish_database(options[:env])
    seeds.each do |filename, ext, collection_name, model|
      if ext == "rb"
        records = eval(File.read(file))
        puts " - Adding data for #{collection_name}..." unless options[:silent]
        insert_rows(records, model)
      elsif ext == "yml" || ext == "yaml"
        data = YAML.load_file(file)
        table = (Hash === data) ? data[data.keys.first] : data
        puts " - Adding data for #{collection_name}..." unless options[:silent]
        insert_rows(records, model)
      else
        lines = File.read(file).split(/\n/)
        puts " - Adding data for #{collection_name}..." unless options[:silent]
        insert_rows_from_csv(lines, model)
      end
    end
  end
  
private
  def insert_rows(rows, model)
    rows.each {|row| model.create!(row) }
  end
  
  def insert_rows_from_csv(lines, model)
    columns = lines.shift.sub(/^#[ ]*/, "").split(/,[ ]*/)
    rows = lines.map do
      values = line.split(/\t|[ ]{2,}/).map {|v| v =~ /^null$/i ? nil : v }
      zip = columns.zip(values).flatten
      Hash[*zip]
    end
    insert_rows(rows, model)
  end
end

module Riggifier
  extend DatabaseSeeding
end