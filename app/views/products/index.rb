
class Products::Index < Stache::Mustache::View
  def manufacturers
    @manufacturers ||= begin
      manufacturers = Manufacturer.includes(:reviewables => [:ratings, :prices]).order(:name)
      #.find_all_by_id([1])
      ManufacturerPresenter.wrap(self, manufacturers)
    end
  end

  def has_manufacturers?
    manufacturers.any?
  end
end
