class Url
  include Mongoid::Document
  include Mongoid::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields
  
  field :url
  field :content
  
  requires_fields :url, :content
end