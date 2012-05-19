
class ReviewablePresenter = Presenter.for(Reviewable) do
  def linked_full_name
    h.link_to(full_name, h.product_path(chipset))
  end

  def linked_chipset_or_yes
    if is_chipset?
      'Yes'
    elsif chipset
      h.link_to(chipset.try(:full_name), h.product_path(chipset))
    end
  end

  def formatted_price
    if current_price
      h.number_to_currency(current_price.amount, :precision => 2)
    end
  end

  def formatted_rating
    if current_rating
      "%s (%s)" % [
        current_rating.raw_value,
        h.pluralize(current_rating.num_reviews, 'review')
      ]
    end
  end
end
