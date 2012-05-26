
ManufacturerPresenter = Presenter.define do
  def locally_linked_name
    view.link_to name, :anchor => webkey
  end

  def link_to_sort_by_name
    _sorted_link_to 'Name', 'full_name'
  end

  def link_to_sort_by_chipset
    _sorted_link_to 'Chipset', 'chipset'
  end

  def link_to_sort_by_price
    _sorted_link_to 'Current Price', 'price'
  end

  def link_to_sort_by_rating
    _sorted_link_to 'Current Rating', 'rating_index'
  end

  def products
    ProductPresenter.present!(super)
  end

  def _sorted_link_to(link_text, sort_key, params={})
    params[:sort_key] = sort_key
    params[:sort_order] = _inv_sort_order_of(sort_key)
    params[:anchor] = webkey
    view.link_to(link_text, params)
  end

  def _inv_sort_order_of(sort_key)
    if view.sort_key == sort_key
      return (view.sort_order == "asc") ? "desc" : "asc"
    else
      return "asc"
    end
  end
end
