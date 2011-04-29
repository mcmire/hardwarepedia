class Manufacturer
  include MongoMapper::Document
  include MongoMapper::Plugins::IdentityMap
  include Hardwarepedia::ModelMixins::RequiresFields
  
  key :name, String
  key :official_url, String
  key :webkey, String
  timestamps!
  
  many :products
  
  before_save :set_webkey
  
  requires_fields :name, :webkey
  
  alias :to_param :webkey
  
  def set_webkey
    #self.webkey = name.gsub(" ", "-").gsub(/[^A-Za-z0-9_-]+/, "").downcase
    self.webkey = name.parameterize
  end
end