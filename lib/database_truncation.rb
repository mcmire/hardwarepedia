module DatabaseTruncation
  def truncate_database(options={})
    options.reverse_merge!(:env => Rails.env)
    puts "Truncating the #{options[:env]} database..." unless options[:silent]
    establish_database(options[:env])
    collections = options[:all] ? Mongoid.database.collections : seeded_collections
    collections.each(&:drop)
  end
end

module Riggifier
  extend DatabaseTruncation
end