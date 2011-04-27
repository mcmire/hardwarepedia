class Image
  include MongoMapper::EmbeddedDocument
  include MongoMapper::Plugins::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields
  
  key :url, String
  key :caption, String
  timestamps!
  
  requires_fields :url
end