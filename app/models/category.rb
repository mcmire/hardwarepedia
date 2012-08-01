
class Category < Sequel::Model
  def self.with_chipsets
    ["Graphics Cards"]
  end

  include Base

  one_to_many :reviewables

  def before_create
    super
    self.webkey ||= name.try(:parameterize)
  end
end

