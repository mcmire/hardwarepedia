
class Manufacturer < Ohm::Model
  collection :reviewables
  collection :products
  collection :chipsets

  validates_presence_of :name
  validates_uniqueness_of :name

  before_save :_set_webkey

  def to_param
    webkey
  end

  def _set_webkey
    self.webkey = name.parameterize
  end
end

