
class Manufacturer < ActiveRecord::Base
  has_many :products

  before_save :_set_webkey

  attr_accessible :name

  def to_param
    webkey
  end

  def _set_webkey
    self.webkey = name.parameterize
  end
end

