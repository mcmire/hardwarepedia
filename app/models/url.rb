
require 'digest/md5'

class Url < Base
  include Ohm::Timestamps

  # Delete all urls, or urls of a certain type
  def self.delete_all(opts={})
    if opts[:type]
      find(:type => opts[:type]).to_a.each {|url| url.delete }
    else
      all.to_a.each {|url| url.delete }
    end
    nil
  end

  attribute :type  # one of "category" or "product"
  attribute :url
  attribute :content_html
  attribute :content_digest
  attribute :state, Type::Integer
  attribute :last_fetched_at, Type::Time

  index :type
  index :state
  unique :url

  expire_in 2.hours

  requires_fields :type, :url, :content_html, :content_digest, :state

  def initialize(attrs={})
    super(attrs)
    self.content_digest ||= (content_html && Digest::MD5.hexdigest(content_html))
    self.state ||= 0
  end

  def incomplete?
    state == 0
  end
  def complete?
    state == 1
  end
end
