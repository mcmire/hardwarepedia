
class ImagePresenter < Presenter
  def img_tag
    view.link_to(view.tag(:img, :src => url, :width => 200), url)
  end
end
