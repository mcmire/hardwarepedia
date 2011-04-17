class Product
  include Mongoid::Document
  include Mongoid::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields
  
  belongs_to :chipset, class_name: "Product"
  belongs_to :category
  belongs_to :manufacturer
  
  has_many :implementations, class_name: "Product", inverse_of: :chipset
  
  # For right now we are just assuming that we are hitting one URL...
  # in the future if multiple URLs are involved maybe we could have a 'data'
  # field that holds info scraped from a URL
  
  field :name
  field :full_name
  field :summary
  field :specs, type: Hash, :default => {}
  field :num_reviews, type: Integer
  field :content_urls, type: Set, :default => Set.new
  field :official_urls, type: Set, :default => Set.new
  field :mention_urls, type: Set, :default => Set.new
  field :market_released_at, type: Date
  field :aggregated_score, type: Float
  field :is_chipset, type: Boolean, default: false
  field :webkey
  
  embeds_many :images
  
  embeds_many :prices, :cascade_callbacks => true
  embeds_many :ratings, :cascade_callbacks => true
  
  embeds_many :reviews, :cascade_callbacks => true
  
  before_save :set_full_name, :set_webkey
  
  requires_fields :name, :full_name, :webkey
  requires_fields :specs, :content_urls, :unless => :is_chipset?
  
  alias :to_param :webkey
  
  def prices_grouped_by_retailer
    self.prices.to_a.group_by(&:retailer_name).each do |retailer_name, prices|
      prices.sort! {|a,b| b.created_at <=> a.created_at }
    end
  end
  def ratings_grouped_by_retailer
    self.ratings.to_a.group_by(&:retailer_name).each do |retailer_name, ratings|
      ratings.sort! {|a,b| b.created_at <=> a.created_at }
    end
  end
  
  def current_rating
    self.ratings.order_by([:created_at, :desc]).first
  end
  def current_price
    self.prices.order_by([:created_at, :desc]).first
  end
  
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