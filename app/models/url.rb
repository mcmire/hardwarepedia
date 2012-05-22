
require 'digest/md5'

class Url < ActiveRecord::Base
  def self.md5(content)
    Digest::MD5.hexdigest(content)
  end

  attr_accessor :doc
end
