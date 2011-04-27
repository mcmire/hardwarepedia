class Price
  include MongoMapper::EmbeddedDocument
  include MongoMapper::Plugins::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields
  
  embedded_in :product
  
  key :url, String
  key :amount, Float
  timestamps!
  
  requires_fields :url, :amount
  
  def retailer_name
    @retailer_name ||= begin
      host = URI.parse(url).host.sub(%r{^www\.}, "")
      Retailer.find_by_host(host).name
    end
  end
end