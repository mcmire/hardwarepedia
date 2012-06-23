
class Image < Ohm::Model
  include Hardwarepedia::ModelMixins::RequiresFields
  include Ohm::DataTypes
  include Ohm::Timestamps

  reference :reviewable, :Reviewable
  attribute :url
  attribute :caption

  requires_fields :reviewable_id, :url
end

