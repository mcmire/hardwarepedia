
require 'digest/md5'

class Url < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields
  include Ohm::Expiration  # our extension

  # Delete all urls, or urls of a certain type
  def self.delete_all(opts={})
    if opts[:type]
      find(:type => opts[:type]).each {|url| url.delete }
    else
      all.each {|url| url.delete }
    end
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
