
require 'digest/md5'

class Url
  def self.find(type, url)
    new(type, url).tap {|u| u.load! }
  end

  def self.create(type, url, opts={})
    new(type, url, opts).tap {|u| u.save }
  end

  # Delete all urls, or urls of a certain type
  def self.delete_all(opts={})
    type = opts[:type] || '*'
    db.keys(typed_key_for(type, '*'))
  end

  def self.key_for(url)
    url_hash = url ? _digest_url(url) : ""
    Hardwarepedia::Util.cache_key(self, url_hash)
  end

  def self.typed_key_for(type, url)
    url_hash = url == '*' ? url : _digest_url(url)
    Hardwarepedia::Util.cache_key(self, type, url_hash)
  end

  def self.cache
    Rails.cache
  end

  def self._digest_url(url)
    Digest::MD5.hexdigest(url)
  end

  attr_accessor :type, :url, :content_html, :content_digest, :state

  # type - one of Category or Product
  def initialize(type, url, opts={})
    self.type = type
    self.url = url
    self.content_html = opts[:content_html]
    self.content_digest = opts[:content_digest] || (
      content_html && Digest::MD5.hexdigest(content_html)
    )
    self.state = opts[:state] || 0
  end

  def incomplete?
    state == 0
  end
  def complete?
    state == 1
  end

  def load!
    hash = db.hgetall(primary_key)
    if hash.blank?
      return false
    else
      self.type = hash['type']
      self.content_html = hash['content_html']
      self.content_digest = hash['content_digest']
      self.state = Integer.from_store(hash['state'])
      return true
    end
  end

  def save
    raise "Cannot save Url: url is missing" unless url
    raise "Cannot save Url: type is missing" unless type
    raise "Cannot save Url: content_html is missing" unless content_html
    raise "Cannot save Url: state is missing" unless state
    hash = {
     'type' => type,
     'url' => url,
     'content_html' => content_html,
     'content_digest' => content_digest,
     'state' => Integer.to_store(state)
    }
    db.pipelined do
      db.hmset(primary_key, *hash.to_a)
      db.hmset(secondary_key, *hash.to_a)
    end
  end

  def primary_key
    self.class.key_for(url)
  end

  def secondary_key
    self.class.typed_key_for(type, url)
  end

  def db
    self.class.db
  end
end
