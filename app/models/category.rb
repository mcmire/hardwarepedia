require 'hardwarepedia/model_mixins/requires_fields'

class Category
  include MongoMapper::Document
  include Hardwarepedia::ModelMixins::RequiresFields

  key :name, String
  key :webkey, String
  timestamps!
  
  before_save :set_webkey
  
  requires_fields :name, :webkey
  
  alias :to_param :webkey
  
  def set_webkey
    #self.webkey = full_name.gsub(" ", "-").gsub(/[^A-Za-z0-9_-]+/, "").downcase
    self.webkey = name.parameterize
  end
end