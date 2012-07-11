
class Reviewable < Base
  # For right now we are just assuming that we are hitting one URL...
  # in the future if multiple URLs are involved maybe we could have a 'data'
  # field that holds info scraped from a URL

  include Ohm::Timestamps

  reference :manufacturer, :Manufacturer
  reference :category, :Category
  reference :chipset, :Chipset  # for products

  collection :implementations, :Product  # for chipsets

  attribute :type # one of chipset or product
  attribute :name
  attribute :full_name
  attribute :webkey
  attribute :summary
  attribute :num_reviews, Type::Integer
  attribute :specs, Type::Hash
  attribute :content_urls, Type::Set
  attribute :official_urls, Type::Set
  attribute :mention_urls, Type::Set
  attribute :released_to_market_on, Type::Date
  attribute :state, Type::Integer

  set :images, :Image
  set :prices, :Price
  set :ratings, :Rating
  set :reviews, :Review

  requires_fields \
    :manufacturer_id, :category_id, :name, :specs, :content_urls,
    :if => :complete?
  requires_fields :chipset_id,
    :if => [:complete?, :product?, :_chipset_needed?]
  fails_save_with("Must have one price") {|r| r.complete? && r.prices.empty? }

  index :type
  index :full_name
  index :state
  unique :webkey

  attr_accessor :is_chipset

  def initialize(attrs={})
    super(attrs)
    self.full_name ||= (manufacturer && [manufacturer.name, name].join(" "))
    self.webkey ||= full_name.try(:parameterize)
    self.content_urls ||= Set.new
    self.official_urls ||= Set.new
    self.mention_urls ||= Set.new
    self.state ||= 0
    self.is_chipset ||= false
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

  def product?
    type == 'product'
  end
  def chipset?
    type == 'chipset'
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
=end

  # Only applicable for products
  def _chipset_needed?
    Category.with_chipsets.include?(category.name)
  end
end
