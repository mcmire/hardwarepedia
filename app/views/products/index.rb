
class Products::Index < Stache::Mustache::View
  def manufacturers
    @manufacturers ||= begin
      #.find_all_by_id([1])
      manufacturers = Manufacturer.all.sort_by(:name)
      ManufacturerPresenter.wrap(self, manufacturers)
    end
  end

  def has_manufacturers?
    manufacturers.any?
  end
end
