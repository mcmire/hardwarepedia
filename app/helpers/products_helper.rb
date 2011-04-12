module ProductsHelper
  def inv_sort_order_of(sort_key)
    if self.sort_key == sort_key
      (self.sort_order == "asc") ? "desc" : "asc"
    else
      return "asc"
    end
  end
end