class Rating
  include Mongoid::Document
  include Mongoid::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields
  
  embedded_in :product
  
  field :merchant_id, type: Integer
  field :raw_value, type: String
  field :value, type: Float
  
  before_save :interpret_raw_value
  
  requires_fields :raw_value, :value
  
  def interpret_raw_value
    if raw_value =~ %r{/}
      num, den = raw_value.split("/")
      self.value = num.to_f / den.to_f
    else
      self.value = raw_value
    end
  end
end