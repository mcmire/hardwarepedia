
class Price < Ohm::Model
  include Ohm::Serialized
  include Ohm::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields

  reference :reviewable, :Reviewable
  reference :reviewable_url, :Url
  attribute :amount, Integer

  unique :reviewable_url

  requires_fields :reviewable_id, :reviewable_url, :amount

  def retailer_name
    @retailer_name ||= begin
      host = URI.parse(url).host.sub(%r{^www\.}, "")
      Retailer.find_by_host(host).name
    end
  end
end
