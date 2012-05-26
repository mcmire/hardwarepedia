
class Reviewable < ActiveRecord::Base
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

  attr_accessible :category, :manufacturer, :name, :full_name, :is_chipset

  validates_uniqueness_of :full_name

  before_save :_set_full_name
  before_save :_set_webkey

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

  def to_param
    webkey
  end

  def _set_full_name
    self.full_name = "#{manufacturer.name} #{name}"
  end

  def _set_webkey
    self.webkey = full_name.parameterize
  end
end
