
class Products::Index < Stache::Mustache::View
  def manufacturers
    @manufacturers ||= begin
      #.find_all_by_id([1])
      manufacturers = Manufacturer.order(:name).all
      ManufacturerPresenter.wrap(self, manufacturers)
    end
  end

  def has_manufacturers?
    manufacturers.any?
  end
end
