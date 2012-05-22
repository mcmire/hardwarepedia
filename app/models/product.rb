
class Product < Reviewable
  include Hardwarepedia::ModelMixins::RequiresFields
  requires_fields :specs, :content_urls

  belongs_to :category
  belongs_to :manufacturer
  belongs_to :chipset
end
