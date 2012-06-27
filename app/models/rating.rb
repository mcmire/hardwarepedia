
class Rating < Ohm::Model
  include Ohm::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields

  reference :reviewable, :Reviewable
  attribute :reviewable_url, :Url
  attribute :raw_value
  attribute :value, Float
  attribute :num_reviews, Integer

  unique :reviewable_url

  requires_fields :reviewable_id, :reviewable_url, :raw_value, :value, :num_reviews

  before_save :_interpret_raw_value

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
