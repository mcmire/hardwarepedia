
require_dependency 'site'
require_dependency 'reviewable'

class Price < Sequel::Model
  include Base

  # TODO: When we add merchants then we need a link to merchant-product
  # and we can get possibly get rid of reviewable_url

  many_to_one :reviewable

  def site_name
    @site_name ||= begin
      host = URI.parse(reviewable_url).host.sub(%r{^www\.}, "")
      Site.find_by_host(host).name
    end
  end
end
