
class Reviewable < ActiveRecord::Base
  include Hardwarepedia::ModelMixins::RequiresFields

  # For right now we are just assuming that we are hitting one URL...
  # in the future if multiple URLs are involved maybe we could have a 'data'
  # field that holds info scraped from a URL

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

  validates_presence_of :category_id, :name
  validates_presence_of :manufacturer_id, :if => :complete?
  validates_uniqueness_of :full_name
  validate :_must_have_a_price, :if => :complete?
  requires_fields :specs, :content_urls, :if => :complete?

  before_save :_set_full_name, :unless => :full_name?
  before_save :_set_webkey, :unless => :webkey?

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
end
