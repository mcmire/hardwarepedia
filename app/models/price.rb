class Price
  include Mongoid::Document
  include Mongoid::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields
  
  embedded_in :product
  
  field :url, :type => String
  field :amount, :type => Float
  
  requires_fields :url, :amount
  
  def retailer_name
    @retailer_name ||= begin
      host = URI.parse(url).host.sub(%r{^www\.}, "")
      Retailer.find_by_host(host).name
    end
  end
end