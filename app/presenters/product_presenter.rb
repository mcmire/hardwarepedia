
class ProductPresenter < ReviewablePresenter
  def linked_chipset
    if chipset
      view.link_to(chipset.try(:full_name), view.product_path(chipset))
    else
      "N/A"
    end
  end
end
