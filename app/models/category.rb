
class Category < ActiveRecord::Base
  before_save :_set_webkey

  def to_param
    webkey
  end

  def _set_webkey
    self.webkey = name.parameterize
  end
end

