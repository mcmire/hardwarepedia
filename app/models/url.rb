
require 'digest/md5'

class Url < Sequel::Model
  include Base

  # Delete all urls, or urls of a certain type
  def self.delete_all(opts={})
    if opts[:type]
      filter(:type => opts[:type]).to_a.each {|url| url.delete }
    else
      all.to_a.each {|url| url.delete }
    end
    nil
  end

  def self.find_fresh(url)
    first {|o| o.url == url && o.expires_at > Time.now }
  end

  def initialize(attrs={})
    super(attrs)
    self.state ||= 0
  end

  def content_digest
    self['content_digest'] ||= (content_html && Digest::MD5.hexdigest(content_html))
  end

  def before_create
    super
    self.expires_at = 2.hours.from_now
  end

  def incomplete?
    state == 0
  end
  def complete?
    state == 1
  end
end
