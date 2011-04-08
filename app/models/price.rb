class Price
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :product
  
  field :merchant_id, type: Integer
  field :amount, type: Float
end