
class Image < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields

  reference :reviewable, :Reviewable
  reference :reviewable_url, :Url
  attribute :url
  attribute :caption

  unique :url

  requires_fields :reviewable_id, :reviewable_url_id, :url
end

