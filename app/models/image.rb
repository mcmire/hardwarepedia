class Image
  include Mongoid::Document
  include Mongoid::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields
  
  embedded_in :product
  
  field :url
  field :caption
  
  requires_fields :url
end