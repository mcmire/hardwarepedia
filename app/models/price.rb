
require_dependency 'retailer'
require_dependency 'reviewable'

class Price < Base
  # TODO: When we add merchants then we need a link to merchant-product
  # and we can get possibly get rid of reviewable_url

  reference :reviewable, :Reviewable
  attribute :reviewable_url
  attribute :amount, Type::Integer
  include Ohm::Timestamps

  unique :reviewable_url

  requires_fields :reviewable_id, :reviewable_url, :amount

  def retailer_name
    @retailer_name ||= begin
      host = URI.parse(url).host.sub(%r{^www\.}, "")
      Retailer.find_by_host(host).name
    end
  end
end
