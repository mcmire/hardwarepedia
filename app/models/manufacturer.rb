class Manufacturer
  include Mongoid::Document
  include Mongoid::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields
  
  field :name
  field :official_url
  
  requires_fields :name
  
  def webkey
    #name.gsub(" ", "-").gsub(/[^A-Za-z0-9_-]+/, "").downcase
    name.parameterize
  end
end