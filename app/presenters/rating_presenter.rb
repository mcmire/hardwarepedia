
class RatingPresenter < Presenter
  def formatted_created_at
    view.format_time_as(:std2, created_at)
  end

  def formatted_raw_value
    raw_value || 'N/A'
  end

  def formatted_num_reviews
    view.pluralize(num_reviews, 'review')
  end

  def formatted_value
    "%s (%s)" % [formatted_raw_value, formatted_num_reviews]
  end
end
