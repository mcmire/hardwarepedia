
class Product < Reviewable
  include Hardwarepedia::ModelMixins::RequiresFields
  requires_fields :specs, :content_urls

  belongs_to :chipset, :class_name => "Product"
end
