
class Category < Sequel::Model
  def self.with_chipsets
    ["Graphics Cards"]
  end

  include Base

  plugin :polymorphic

  one_to_many :reviewables
  one_to_many :urls, :as => :resource

  def before_create
    super
    self.webkey ||= name.try(:parameterize)
  end
end

