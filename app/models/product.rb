
class Product < Reviewable
  reference :chipset, :Chipset

  requires_fields :chipset_id,
    :if => [:complete?, :_chipset_needed?]

  def _chipset_needed?
    Category.with_chipsets.include?(category.name)
  end
end
