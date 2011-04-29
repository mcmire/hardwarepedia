require 'digest/md5'
require 'hardwarepedia/model_mixins/requires_fields'

class Url
  def self.md5(content)
    Digest::MD5.hexdigest(content)
  end
  
  include MongoMapper::Document
  include Hardwarepedia::ModelMixins::RequiresFields
  
  attr_accessor :doc
  
  key :url, String
  key :body, String
  key :content_md5, String
  timestamps!
  
  requires_fields :url, :body, :content_md5
end