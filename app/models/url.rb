
require 'digest/md5'

class Url
  include ActiveModel::Validations
  include ActiveModel::AttributeMethods

  class << self
    CACHE_NS = 'Url'.freeze

    def find(url)
      _cache.read _cache_key_for(url)
    end

    def create(attrs={})
      new(attrs).tap {|u| u.save }
    end

    def digest_content(content)
      Digest::MD5.hexdigest(content)
    end

    # Delete all urls, or urls of a certain type
    def delete_all(opts={})
      kind = opts[:kind] || '[^:]+'
      _cache.delete_matched Regexp.new(_typed_cache_key_for(kind, nil))
    end

    def _cache_key_for(url)
      url_hash = url ? Digest::MD5.hexdigest(url) : ""
      Hardwarepedia::Util.cache_key(CACHE_NS, url_hash)
    end

    def _typed_cache_key_for(kind, url)
      url_hash = url ? Digest::MD5.hexdigest(url) : ""
      Hardwarepedia::Util.cache_key("#{CACHE_NS}-#{kind}", url_hash)
    end

    def _cache
      Rails.cache
    end
  end

  validates_presence_of :url, :content_html, :content_md5

  attribute_method_suffix '=', '?'
  define_attribute_methods [:url, :kind, :content_html, :content_md5, :state]

  def initialize(attrs={})
    @attributes = {:state => 0}
    @attributes.merge!(attrs)
  end

  attr_reader :attributes

  # XXX : Is this actually used?
  attr_accessor :doc

  def attribute(key)
    @attributes[key.to_sym]
  end
  def attribute=(key, value)
    @attributes[key.to_sym] = value
  end
  def attribute?(key)
    @attributes[key.to_sym].present?
  end

  def read_attribute_for_validation(key)
    attribute(key)
  end

  def save
    _cache.write _cache_key, self
  end

  def incomplete?
    state == 0
  end
  def complete?
    state == 1
  end

  def _cache_key
    self.class._cache_key_for(url)
  end

  def _cache
    self.class._cache
  end
end
