
class ApplicationController < ActionController::Base
  # The default behavior in Rails 3 is to include all helpers, all the time.
  # Even though this was also a default in Rails 2 (albeit unofficial), it's
  # prone to cause more problems in my opinion. For instance, it makes it
  # impossible to have two helper methods with the same name (as the last helper
  # will, perhaps surprisingly clobber any existing helpers). In any case, from
  # a theoretical standpoint, including all of the helpers is kind of silly
  # -- as one commenter here [1] wrote, you might as well put all of your
  # helpers in ApplicationHelper.
  #
  # We prefer to keep one helper for each controller. Of course, you aren't
  # bound by this -- since you have to include helpers explicitly in your
  # controller anyway, it's more flexible as you can really include whatever
  # helper you want.
  #
  # This must be above everything else.
  #
  # [1]: https://rails.lighthouseapp.com/projects/8994/tickets/5348-visibility-of-helpers-seems-all-wrong
  #
  clear_helpers

  # Turn on cross-site request forgery protection.
  # http://guides.rubyonrails.org/security.html#cross-site-request-forgery-csrf
  #
  protect_from_forgery

  # This lets you sanely define values that you can use anywhere in your views
  # (as well as your controllers).
  #
  # Read the explanation in
  # lib/hardwarepedia/controller_mixins/limited_exposure.rb for more.
  #
  include Hardwarepedia::ControllerMixins::LimitedExposure

  # Add controller helpers which are useful in tagging the <body> tag with info
  # like the current controller and action, etc.
  #
  include Hardwarepedia::ControllerMixins::TaggedBody

  # Add a default window title
  window_title "Hardwarepedia"
end
