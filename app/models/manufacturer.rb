class Manufacturer
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name
  field :official_url
end