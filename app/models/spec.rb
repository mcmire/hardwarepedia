class Spec
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :product
  
  field :name
  field :value
  field :type
  
  def <=>(other)
    SpecTypes.compare(type, self, other)
  end
end