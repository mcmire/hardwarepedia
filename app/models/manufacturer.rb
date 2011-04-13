class Manufacturer
  include Mongoid::Document
  include Mongoid::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields
  
  field :name
  field :official_url
  field :webkey
  
  before_save :set_webkey
  
  requires_fields :name, :webkey
  
  alias :to_param :webkey
  
  def set_webkey
    #self.webkey = name.gsub(" ", "-").gsub(/[^A-Za-z0-9_-]+/, "").downcase
    self.webkey = name.parameterize
  end
end