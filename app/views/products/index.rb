
class Products::Index < Stache::Mustache::View
  def manufacturers
    @manufacturers ||= begin
      manufacturers = Manufacturer.includes(:products => [:ratings, :prices]).order(:name).limit(1)
      ManufacturerPresenter.wrap(self, manufacturers)
    end
  end

  def has_manufacturers?
    manufacturers.any?
  end
end
