
class ReviewablePresenter < Presenter
  def chipset
    return @chipset if defined?(@chipset)
    chipset = reviewable.chipset
    @chipset = chipset ? ReviewablePresenter.new(self, chipset) : nil
  end

  def implementations
    @implementations ||= ReviewablePresenter.wrap(self, reviewable.implementations)
  end

  def content_urls
    @content_urls ||= UrlPresenter.wrap(self, reviewable.content_urls)
  end

  def images
    @images ||= ImagePresenter.wrap(self, reviewable.images)
  end

  def specs
    @specs ||= reviewable.specs.map { |name, value|
      {:name => name, :value => value}
    }
  end

  def prices_grouped_by_site
    @prices_grouped_by_site ||=
      reviewable.prices_grouped_by_site.map { |group|
        {:site_name => group[:site_name],
         :prices => PricePresenter.wrap(self, group[:prices])}
      }
  end

  def ratings_grouped_by_site
    @ratings_grouped_by_site ||=
      reviewable.ratings_grouped_by_site.map { |group|
        {:site_name => group[:site_name],
         :ratings => RatingPresenter.wrap(self, group[:ratings])}
      }
  end

  #---

  def linked_full_name
    view.link_to(reviewable.full_name, view.reviewable_path(:webkey => webkey))
  end

  def linked_chipset
    if type == 'product'
      if chipset
        chipset.linked_full_name
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
    current_rating.try(:raw_value) || 'N/A'
  end

  def formatted_num_reviews
    view.pluralize(current_num_reviews, 'review')
  end

  def formatted_rating_with_num_reviews
    "%s (%s)" % [formatted_rating, formatted_num_reviews]
  end
end
