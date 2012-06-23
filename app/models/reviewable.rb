
class Reviewable < ActiveRecord::Base
  # include Hardwarepedia::ModelMixins::RequiresFields

  # For right now we are just assuming that we are hitting one URL...
  # in the future if multiple URLs are involved maybe we could have a 'data'
  # field that holds info scraped from a URL

=begin
  serialize :specs, Hash
  serialize :content_urls, Set
  serialize :official_urls, Set
  serialize :mention_urls, Set

  belongs_to :category
  belongs_to :manufacturer

  has_many :images
  has_many :prices
  has_many :ratings
  has_many :reviews

  validates_presence_of :category_id, :name, :if => :complete?
  validates_presence_of :manufacturer_id, :if => :complete?
  validate :_must_have_a_price, :if => :complete?
  requires_fields :specs, :content_urls, :if => :complete?

  before_save :_set_full_name, :unless => :full_name?
  before_save :_set_webkey, :unless => :webkey?
=end

  def self.find_or_create(name)
    new(name).tap {|c| c.load_or_save! }
  end

  attr_accessor \
    :type, :name, :full_name,
    :chipset_id, :webkey, :summary, :num_reviews, :market_release_date, :state,
    :created_at, :updated_at
  attr_reader \
    :manufacturer, :manufacturer_name,
    :category, :category_name

  # type - one of Chipset or Product
  def initialize(type, manufacturer, name, opts={})
    self.type = type
    self.manufacturer = manufacturer
    self.name = name
    self.full_name = [manufacturer_name, name].join(" ")

    self.category = opts[:category]
    self.chipset = opts[:chipset]
    self.summary = opts[:summary]
    self.num_reviews = opts[:num_reviews]
    self.market_release_date = opts[:market_release_date]
    self.webkey = opts[:webkey] || full_name.parameterize
    self.state = opts[:state] || 0
    self.created_at = opts[:created_at]
    self.updated_at = opts[:updated_at]
  end

  def manufacturer=(manufacturer)
    @manufacturer = manufacturer
    @manufacturer_name = manufacturer.try(:name)
  end

  def category=(category)
    @category = category
    @category_name = category.try(:name)
  end

  def chipset=(chipset)
    @chipset = chipset
    @chipset_id = 
  end

  def load_or_save!
    load! or save
    return nil
  end

  def load!
    hash = db.hgetall(primary_key)
    if hash.blank?
      return false
    else
      self.category = Category.new(hash['category_name'])
      self.chipset_id = hash['chipset_id']
      self.summary = hash['summary']
      self.num_reviews = Integer.from_store(hash['num_reviews'])
      self.market_release_date = Date.from_store(hash['market_release_date'])
      self.webkey = hash['webkey']
      self.state = Integer.from_store(hash['state'])
      self.created_at = Time.from_store(hash['created_at'])
      self.updated_at = Time.from_store(hash['updated_at'])
    end
  end

  def save
    hash = {
      :type => type,
      :manufacturer_name => manufacturer_name,
      :name => name,
      :full_name => full_name,
      :category_name => category_name,
      :chipset_id => chipset_id
    }
    db.hmset(primary_key, *fields.to_a)
  end

=begin
  def prices_grouped_by_retailer
    grouped_prices = self.prices.to_a.group_by(&:retailer_name)
    grouped_prices.each do |retailer_name, prices|
      prices.sort! {|a,b| b.created_at <=> a.created_at }
    end
    grouped_prices
  end
  def ratings_grouped_by_retailer
    grouped_ratings = self.ratings.to_a.group_by(&:retailer_name)
    grouped_ratings.each do |retailer_name, ratings|
      ratings.sort! {|a,b| b.created_at <=> a.created_at }
    end
    grouped_ratings
  end

  def current_rating
    self.ratings.sort {|a,b| b.created_at <=> a.created_at }.first
  end
  def current_price
    self.prices.sort {|a,b| b.created_at <=> a.created_at }.first
  end

  def incomplete?
    state == 0
  end
  def complete?
    state == 1
  end

  def to_param
    webkey
  end

  def _set_full_name
    self.full_name = [manufacturer.name, name].join(" ")
  end

  def _set_webkey
    self.webkey = full_name.parameterize
  end

  def _must_have_a_price
    if prices.empty?
      self.errors[:prices] << "This #{type} must have at least one price"
    end
  end
=end
end
