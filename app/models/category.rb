
class Category < Ohm::Model
  include Ohm::DataTypes
  include Hardwarepedia::ModelMixins::RequiresFields

  def self.with_chipsets
    ["Graphics Cards"]
  end

  attribute :name
  attribute :webkey
  attribute :state, Type::Integer

  index :state
  index :name
  unique :webkey

  requires_fields :name, :webkey, :state

  def initialize(attrs={})
    super(attrs)
    self.webkey ||= name.try(:parameterize)
    self.state ||= 0
  end
end

