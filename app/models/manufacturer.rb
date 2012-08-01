
require_dependency 'reviewable'

class Manufacturer < Sequel::Model
  include Base

  one_to_many :reviewables

  def before_create
    super
    self.webkey ||= name.try(:parameterize)
  end

  def to_param
    webkey
  end
end

