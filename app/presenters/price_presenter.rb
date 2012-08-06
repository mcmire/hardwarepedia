
class PricePresenter < Presenter
  def formatted_created_at
    view.format_time_as(:std2, created_at)
  end

  def formatted_amount
    view.number_to_currency(amount / 100)
  end
end
