
class Rating < ActiveRecord::Base
  belongs_to :reviewable

  attr_accessible :url, :raw_value, :num_reviews

  before_save :_interpret_raw_value

  def retailer_name
    @retailer_name ||= begin
      host = URI.parse(url).host.sub(%r{^www\.}, "")
      Retailer.find_by_host(host).name
    end
  end

  def _interpret_raw_value
    if raw_value =~ %r{/}
      num, den = raw_value.split("/")
      self.value = num.to_f / den.to_f
    else
      self.value = raw_value
    end
  end
end
