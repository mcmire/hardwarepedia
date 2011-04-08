class Photo
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :product
  
  field :url
  field :caption
end