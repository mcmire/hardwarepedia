
class Category < Ohm::Model
  include Hardwarepedia::ModelMixins::RequiresFields
  include Ohm::Serialized

  def self.with_chipsets
    ["Graphics Cards"]
  end

  attribute :name
  attribute :webkey, :default => lambda {|c| c.name.parameterize }
  attribute :state, :default => 0

  unique :name
  unique :webkey

  requires_fields :name, :webkey, :state
end

