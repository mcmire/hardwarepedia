
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

  serialize_attributes :set, \
    :content_urls, :official_urls, :mention_urls

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
=end

  def current_rating
    self.ratings.sort {|a,b| b.created_at <=> a.created_at }.first
  end
  def current_price
    self.prices.sort {|a,b| b.created_at <=> a.created_at }.first
  end
end
