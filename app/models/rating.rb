require 'hardwarepedia/model_mixins/requires_fields'

class Rating
  include MongoMapper::EmbeddedDocument
  include MongoMapper::Plugins::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields
  
  key :url, String
  key :raw_value, String
  key :value, Float
  key :num_reviews, Integer
  timestamps!
  
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