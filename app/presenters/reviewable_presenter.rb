
ReviewablePresenter = Presenter.define do
  def linked_full_name
    view.link_to(full_name, view.product_path(self))
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
