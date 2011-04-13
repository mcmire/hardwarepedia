class Product
  include Mongoid::Document
  include Mongoid::Timestamps
  include Hardwarepedia::ModelMixins::RequiresFields
  
  belongs_to :category
  belongs_to :chipset_manufacturer
  belongs_to :manufacturer
  
  # For right now we are just assuming that we are hitting one URL...
  # in the future if multiple URLs are involved maybe we could have a 'data'
  # field that holds info scraped from a URL
  
  field :name
  field :full_name
  field :summary
  field :price, type: Float
  field :specs, type: Hash
  field :num_reviews, type: Integer
  field :content_urls, type: Set
  field :official_urls, type: Set
  field :mention_urls, type: Set
  field :market_released_at, type: Date
  field :aggregated_score, type: Float
  field :chipset, type: Boolean
  
  #embeds_many :prices
  #embeds_many :ratings
  embeds_many :reviews
  embeds_many :images
  
  embeds_one :rating
  
  before_save :set_full_name
  
  requires_fields :name, :price, :specs, :num_reviews, :content_urls
  
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