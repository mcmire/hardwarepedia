
require 'digest/md5'

class Url < ActiveRecord::Base
  def self.md5(content)
    Digest::MD5.hexdigest(content)
  end

  attr_accessible :url, :body, :content_md5

  attr_accessor :doc
end
