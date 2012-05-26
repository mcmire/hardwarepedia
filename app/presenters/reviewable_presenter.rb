
ReviewablePresenter = Presenter.for(Reviewable) do
  def linked_full_name
    view.link_to(full_name, h.product_path(chipset))
  end

  def linked_chipset_or_yes
    if is_chipset?
      'Yes'
    elsif chipset
      view.link_to(chipset.try(:full_name), view.product_path(chipset))
    end
  end

  def formatted_price
    if current_price
      view.number_to_currency(current_price.amount, :precision => 2)
    end
  end

  def formatted_rating
    if current_rating
      "%s (%s)" % [
        current_rating.raw_value,
        view.pluralize(current_rating.num_reviews, 'review')
      ]
    end
  end
end
