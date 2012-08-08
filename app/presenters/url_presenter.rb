
class UrlPresenter < Presenter
  def linked_url
    view.link_to(nil, url, :target => :blank)
  end
end
