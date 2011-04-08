class Rating
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :product
  
  field :merchant_id, type: Integer
  field :raw_value, type: String
  field :value, type: Float
  
  def interpret_raw_value
  end
end