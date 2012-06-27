
class Manufacturer < Ohm::Model
  include Ohm::DataTypes
  include Hardwarepedia::ModelMixins::RequiresFields

  collection :reviewables, :Reviewable
  collection :products, :Product
  collection :chipsets, :Chipset

  attribute :name
  attribute :webkey

  requires_fields :name, :webkey

  def initialize(attrs={})
    self.webkey ||= name.try(:parameterize)
  end

  def to_param
    webkey
  end
end

