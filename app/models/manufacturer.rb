
class Manufacturer < Ohm::Model
  include Hardwarepedia::ModelMixins::RequiresFields
  include Ohm::Serialized

  collection :reviewables
  collection :products
  collection :chipsets

  attribute :name
  attribute :webkey, :default => lambda {|m| m.name.parameterize }

  requires_fields :name, :webkey

  def to_param
    webkey
  end
end

