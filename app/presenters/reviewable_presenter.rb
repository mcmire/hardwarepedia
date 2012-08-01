
class ReviewablePresenter < Presenter
  def linked_full_name
    view.link_to(full_name, view.product_path(self))
  end

  def linked_chipset
    if type == 'product'
      if chipset
        view.link_to(chipset.try(:full_name), view.product_path(chipset))
      else
        "N/A"
      end
    else
      "Yes"
    end
  end

  def formatted_price
    if current_price
      view.number_to_currency(current_price.amount.to_f / 100, :precision => 2)
    else
      "Not known (yet)"
    end
  end

  def formatted_rating
    if current_rating
      "%s (%s)" % [
        current_rating.raw_value,
        view.pluralize(current_rating.num_reviews, 'review')
      ]
    else
      "N/A"
    end
  end
end
