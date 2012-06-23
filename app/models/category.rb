
class Category < Ohm::Model
  include Hardwarepedia::ModelMixins::RequiresFields
  include Ohm::DataTypes
  include Ohm::Timestamps

  attribute :name
  attribute :webkey
  attribute :state, Type::Integer

  unique :name
  unique :webkey

  requires_fields :name, :webkey, :state

  def initialize(attrs={})
    super(attrs)
    self.webkey ||= name.parameterize
    self.state ||= 0
  end
end

