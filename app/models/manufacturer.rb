
require_dependency 'reviewable'

class Manufacturer < Base
  collection :reviewables, :Reviewable
  # collection :products, :Product
  # collection :chipsets, :Chipset

  attribute :name
  attribute :webkey

  unique :name
  unique :webkey

  requires_fields :name, :webkey

  def initialize(attrs={})
    super(attrs)
    self.webkey ||= name.try(:parameterize)
  end

  # simply defining after_save makes some magic happen...
  def after_save
  end

  def to_param
    webkey
  end
end

