
class Image < Ohm::Model
  include Ohm::Serialized
  include Ohm::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields

  reference :reviewable, :Reviewable
  reference :reviewable_url, :Url
  attribute :url
  attribute :caption

  unique :url

  requires_fields :reviewable_id, :reviewable_url, :url
end

