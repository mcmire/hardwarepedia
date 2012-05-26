
class Products::Index < Stache::Mustache::View
  def manufacturers
    @manufacturers ||= ManufacturerPresenter.present!(
      Manufacturer.includes(:products => [:ratings, :prices]).order(:name).limit(1)
    )
  end

  def has_manufacturers?
    manufacturers.any?
  end
end
