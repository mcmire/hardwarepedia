
require_dependency 'retailer'
require_dependency 'reviewable'

class Rating < Base
  # TODO: When we add merchants then we need a link to merchant-product
  # and we can get possibly get rid of reviewable_url

  reference :reviewable, :Reviewable
  attribute :reviewable_url
  attribute :raw_value
  attribute :value, Type::Float
  attribute :num_reviews, Type::Integer
  include Ohm::Timestamps

  unique :reviewable_url

  requires_fields \
    :reviewable_id, :reviewable_url, :raw_value, :value, :num_reviews

  def before_save
    _interpret_raw_value
  end

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
