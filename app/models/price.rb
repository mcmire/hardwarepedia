
require_dependency 'retailer'
require_dependency 'reviewable'

class Price < Sequel::Model
  include Base

  # TODO: When we add merchants then we need a link to merchant-product
  # and we can get possibly get rid of reviewable_url

  many_to_one :reviewable

  def retailer_name
    @retailer_name ||= begin
      host = URI.parse(url).host.sub(%r{^www\.}, "")
      Retailer.find_by_host(host).name
    end
  end
end
