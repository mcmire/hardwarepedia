
require_dependency 'reviewable'

class Image < Base
  # TODO: When we add merchants then we need a link to merchant-product
  # and we can get possibly get rid of reviewable_url

  reference :reviewable, :Reviewable
  attribute :reviewable_url
  attribute :url
  attribute :caption
  include Ohm::Timestamps

  unique :url

  requires_fields :reviewable_id, :reviewable_url, :url
end

