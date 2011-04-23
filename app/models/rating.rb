class Rating
  include Mongoid::Document
  include Mongoid::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields
  
  embedded_in :product
  
  field :url, :type => String
  field :raw_value, :type => String
  field :value, :type => Float
  field :num_reviews, :type => Integer
  
  before_save :interpret_raw_value
  
  requires_fields :url, :raw_value, :value
  
  def retailer_name
    @retailer_name ||= begin
      host = URI.parse(url).host.sub(%r{^www\.}, "")
      Retailer.find_by_host(host).name
    end
  end
  
  def interpret_raw_value
    if raw_value =~ %r{/}
      num, den = raw_value.split("/")
      self.value = num.to_f / den.to_f
    else
      self.value = raw_value
    end
  end
end