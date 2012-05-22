
class Price < ActiveRecord::Base
  attr_accessible :url, :amount

  def retailer_name
    @retailer_name ||= begin
      host = URI.parse(url).host.sub(%r{^www\.}, "")
      Retailer.find_by_host(host).name
    end
  end
end
