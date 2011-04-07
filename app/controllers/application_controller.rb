class ApplicationController < ActionController::Base
  # The default behavior in Rails 3 is to include all helpers, all the time.
  # Even though this was also a default in Rails 2 (albeit unofficial), it's
  # prone to cause more problems in my opinion. For instance, it makes it
  # impossible to have two helpers with the same name. From a theoretical
  # standpoint, as one commenter here [1] wrote, you might as well put all of
  # your helpers in ApplicationHelper.
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
  # Read the (admittedly rather long) explanation in
  # lib/advertiser_web/controller_mixins/limited_exposure.rb for more.
  #
  extend ProjectXenon::ControllerMixins::LimitedExposure
  
  # Add helpful methods which let us ultimately emulate what inherited_resources
  # did before (except without all the magic). Each controller will get class
  # methods #collection and #resource (that let you set the "collection" and
  # "resource" values), and each view will get methods like #resource_id,
  # #resource_class, #resource_name, etc.
  #
  extend ProjectXenon::ControllerMixins::Resources
  helper ProjectXenon::ViewMixins::Resources
  
  # Add view helpers which are useful in tagging the <body> tag with info
  # like the current controller and action, etc.
  helper ProjectXenon::ViewMixins::TaggedBody
  
  # Set a global window title
  #
  add_window_title "PROJECT XENON BITCHEZZZZ"
end
