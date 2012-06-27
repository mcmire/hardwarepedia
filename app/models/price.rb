
class Price < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields

  reference :reviewable, :Reviewable
  reference :reviewable_url, :Url
  attribute :amount, Type::Integer

  unique :reviewable_url_id

  requires_fields :reviewable_id, :reviewable_url_id, :amount

  def retailer_name
    @retailer_name ||= begin
      host = URI.parse(url).host.sub(%r{^www\.}, "")
      Retailer.find_by_host(host).name
    end
  end
end
