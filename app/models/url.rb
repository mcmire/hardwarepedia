require 'digest/md5'

class Url
  def self.md5(content)
    Digest::MD5.hexdigest(content)
  end
  
  include Mongoid::Document
  include Mongoid::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields
  
  attr_accessor :doc
  
  #field :retailer_name
  #field :category_name
  field :url
  field :body
  field :content_md5
  
  requires_fields :url, :body, :content_md5
end