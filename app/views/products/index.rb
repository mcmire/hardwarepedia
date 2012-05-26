
class Products::Index < Stache::Mustache::View
  def manufacturers
    @manufacturers ||= ManufacturerPresenter.includes(:products).order(:name).to_a
  end

  def has_manufacturers?
    manufacturers.any?
  end
end
