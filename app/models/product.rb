
class Product < Reviewable
  belongs_to :category
  belongs_to :manufacturer
  belongs_to :chipset

  validates_presence_of :chipset_id, :if => [:complete?, :_chipset_needed?]

  def _chipset_needed?
    category.name == "Graphics Cards"
  end
end
