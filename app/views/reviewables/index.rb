
class Reviewables::Index < Stache::Mustache::View
  def manufacturers
    @manufacturers ||= ManufacturerPresenter.wrap(self, view.manufacturers)
  end

  def has_manufacturers?
    manufacturers.any?
  end
end
