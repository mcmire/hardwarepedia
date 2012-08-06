
class Reviewables::Show < Stache::Mustache::View
  def reviewable
    @reviewable ||= ReviewablePresenter.new(self, view.reviewable)
  end
end
