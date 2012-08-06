
class Reviewable < Sequel::Model
  include Base

  # For right now we are just assuming that we are hitting one URL...
  # in the future if multiple URLs are involved maybe we could have a 'data'
  # field that holds info scraped from a URL

  many_to_one :manufacturer
  many_to_one :category
  many_to_one :chipset, :class => self,
    :conditions => {:type => 'chipset'}
  one_to_many :implementations, :class => self, :key => :chipset_id,
    :conditions => {:type => 'product'}

  one_to_many :images
  one_to_many :prices
  one_to_many :ratings
  one_to_many :reviews

  serialize_attributes :json, :specs
  serialize_attributes :set, \
    :content_urls, :official_urls, :mention_urls

  def self.sorted(manufacturer, sort_key, sort_order)
    reviewables = manufacturer.reviewables
    # Schwartzian transform
    sort_rule = _sort_rules[sort_key] or raise "Unknown sort key '#{sort_key}'"
    tmp = eval %< reviewables.map { |p| [p, #{sort_rule}] } >
    case sort_order
      when "desc" then tmp.sort! {|a,b| b[1] <=> a[1] }
      else             tmp.sort! {|a,b| a[1] <=> b[1] }
    end
    tmp.map {|x| x[0] }
  end

  def self._sort_rules
    return {
      "full_name" => "p.full_name.downcase",
      "price" => "(p.current_price.try(:amount) || -1)",
      "rating_index" => "[(p.current_rating.try(:value) || 0), p.current_num_reviews]"
    }
  end

  attr_accessor :is_chipset

  def initialize(attrs={})
    super(attrs)
    self.content_urls ||= Set.new
    self.official_urls ||= Set.new
    self.mention_urls ||= Set.new
    self.state ||= 0
  end

  def before_create
    super
    self.webkey ||= full_name.try(:parameterize)
  end

  def before_save
    super
    self.full_name ||= (manufacturer && [manufacturer.name, name].join(" "))
    self.num_prices = prices.size
  end

  def validate
    super
    if complete?
      validates_presence [:manufacturer_id, :category_id, :name, :specs, :content_urls]
      errors.add(:prices, 'is empty') if prices_dataset.empty?
    end
    if complete? && product? && Category.with_chipsets.include?(category.name)
      validates_presence :chipset_id
    end
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

  def prices_grouped_by_retailer
    # TODO: sqlize
    grouped_prices = self.prices.to_a.group_by(&:retailer_name)
    grouped_prices.map { |retailer_name, prices|
      prices.sort! {|a,b| b.created_at <=> a.created_at }
      {:retailer_name => retailer_name, :prices => prices}
    }
  end

  def ratings_grouped_by_retailer
    # TODO: sqlize
    grouped_ratings = self.ratings.to_a.group_by(&:retailer_name)
    grouped_ratings.map { |retailer_name, ratings|
      ratings.sort! {|a,b| b.created_at <=> a.created_at }
      {:retailer_name => retailer_name, :ratings => ratings}
    }
  end

  def current_rating
    @current_rating ||=
      self.ratings.sort {|a,b| b.created_at <=> a.created_at }.first
  end

  def current_num_reviews
    current_rating.try(:num_reviews) || 0
  end

  def current_price
    @current_price ||=
      self.prices.sort {|a,b| b.created_at <=> a.created_at }.first
  end

  def has_specs?
    !specs.empty?
  end

  def has_images?
    !images.empty?
  end

  def has_prices?
    !prices.empty?
  end

  def has_ratings?
    !ratings.empty?
  end
end
