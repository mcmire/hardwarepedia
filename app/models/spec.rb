class Spec
  include MongoMapper::EmbeddedDocument
  include MongoMapper::Plugins::Timestamps
  
  key :name, String
  key :value, String
  key :type, String
  timestamps!
  
  def <=>(other)
    SpecTypes.compare(type, self, other)
  end
end