class Category
  include Mongoid::Document
  include Mongoid::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields

  field :name
  
  requires_fields :name
end