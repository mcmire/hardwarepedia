
class Reviewable < Ohm::Model
  # For right now we are just assuming that we are hitting one URL...
  # in the future if multiple URLs are involved maybe we could have a 'data'
  # field that holds info scraped from a URL

  include Hardwarepedia::ModelMixins::RequiresFields
  include Ohm::DataTypes
  include Ohm::Timestamps

  reference :manufacturer, :Manufacturer
  reference :category, :Category
  reference :chipset, :Chipset

  attribute :type # one of Chipset or Product
  attribute :name
  attribute :full_name
  attribute :webkey
  attribute :summary
  attribute :num_reviews, Type::Integer
  attribute :specs, Type::Hash
  set :content_urls
  set :official_urls
  set :mention_urls
  attribute :market_release_date, Type::Date
  attribute :state, Type::Integer

  collection :images
  collection :prices
  collection :ratings
  collection :reviews

  requires_fields \
    :manufacturer_id, :category_id, :name, :first_price, :specs, :content_urls,
    :if => :complete?
  fails_save_with("Must have one price") {|r| r.prices.empty? }

  def initialize(attrs={})
    super(attrs)
    self.full_name ||= (
      manufacturer && [manufacturer.name, name].join(" ")
    )
    self.webkey ||= full_name.try(:parameterize)
    self.state ||= 0
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
end
