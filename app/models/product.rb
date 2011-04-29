require 'hardwarepedia/model_mixins/requires_fields'

class Product
  include MongoMapper::Document
  include MongoMapper::Plugins::IdentityMap
  include Hardwarepedia::ModelMixins::RequiresFields
  
  # For right now we are just assuming that we are hitting one URL...
  # in the future if multiple URLs are involved maybe we could have a 'data'
  # field that holds info scraped from a URL
  
  key :name
  key :full_name
  key :summary
  key :specs, Hash, :default => {}
  key :num_reviews, Integer
  key :content_urls, Set, :default => Set.new
  key :official_urls, Set, :default => Set.new
  key :mention_urls, Set, :default => Set.new
  key :market_released_at, Date
  key :aggregated_score, Float
  key :is_chipset, Boolean, :default => false
  key :webkey
  timestamps!
  
  # Referenced associations
  belongs_to :chipset, :class_name => "Product"
  belongs_to :category
  belongs_to :manufacturer
  many :implementations, :class_name => "Product"
  
  # Embedded associations
  many :images
  many :prices
  many :ratings
  many :reviews
  
  before_save :set_full_name, :set_webkey
  
  requires_fields :name, :full_name, :webkey
  requires_fields :specs, :content_urls, :unless => :is_chipset?
  
  alias :to_param :webkey
  
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
  
=begin
  def calculate_avg_price
    self.avg_price = prices.avg
  end
  def add_price
    prices.create(price)
    calculate_avg_price
  end
  
  def calculate_avg_rating
    self.avg_rating = ratings.avg
  end
  def add_rating
    ratings.create(rating)
    calculate_avg_rating
  end
  
  def calculate_avg_benchmark
    self.avg_benchmark = benchmarks.avg
  end
  def add_benchmark
    benchmarks.create(benchmark)
    calculate_avg_benchmark
  end
=end
  
  def set_full_name
    self.full_name = "#{manufacturer.name} #{name}"
  end
  
  def set_webkey
    #self.webkey = full_name.gsub(" ", "-").gsub(/[^A-Za-z0-9_-]+/, "").downcase
    self.webkey = full_name.parameterize
  end
  
  def as_json(options={})
    json = super
    json.merge!(
      :category_name => category.name,
      :chipset_manufacturer_name => chipset_manufacturer.try(:name),
      :manufacturer_name => manufacturer.name,
      :images => images.map(&:as_json)
    )
    json
  end
end