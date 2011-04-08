class Product
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :product
  belongs_to :category
  belongs_to :chipset_manufacturer
  belongs_to :manufacturer
  
  field :name
  field :full_name
  field :summary
  field :specs, type: Hash
  field :official_urls, type: Array
  field :purchase_urls, type: Array
  field :mention_urls, type: Array
  field :market_released_at, type: Date
  field :aggregated_score, type: Float
  field :chipset, type: Boolean
  
  embeds_many :specs
  embeds_many :prices
  embeds_many :ratings
  embeds_many :reviews
  embeds_many :photos
  
  before_save :set_full_name
  
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
end