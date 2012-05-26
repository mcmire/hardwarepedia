
ProductPresenter = ReviewablePresenter.define do
  def linked_chipset
    raise 'ok'
    if chipset
      view.link_to(chipset.try(:full_name), view.product_path(chipset))
    else
      "N/A"
    end
  end
end
