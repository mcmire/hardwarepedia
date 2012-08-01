
require 'sequel/plugins/serialization'

Sequel::Plugins::Serialization.register_format(:set,
  # serialize
  lambda {|v| MultiJson.dump(v.to_a) },
  # deserialize
  lambda {|v| Set.new(MultiJson.load(v)) }
)

