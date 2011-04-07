module ProjectXenon
  module ControllerMixins
    # This is a module that lets you cleanly and clearly define values that you
    # can use anywhere in your controllers and views. It's similar to the
    # [decent_exposure](http://github.com/voxdolo/decent_exposure) gem, but it
    # works more simply (and doesn't have a default action when you don't pass
    # a block to #expose, since we don't need no magick here).
    #
    # Use it like so:
    #
    #     class SomeController < ActionController::Base
    #       extend LimitedExposure
    #       expose(:product) { Product.find(params[:id]) }
    #     end
    #
    # == The use case for helpers
    #
    # Oftentimes you will need to set instance variables in your controller
    # actions for use later in your controllers. Most likely you're setting these
    # because you really want to use them in your views. The problem arises when
    # you have a partial in your view, such as for a form. By default, Rails
    # propagates instance variables through to partials. However, I think this is
    # bad practice because it's difficult for other people to know what's going
    # on. So a better way is to pass instance variables through as local variables
    # using the `:locals` option to `render :partial`. However, what if you have
    # nested partials? Then you're passing local variables through. At this point,
    # you have an interface disconnect --- instance variables in one view,
    # things-that-look-like-helpers in another. You might as well make it easy for
    # everyone and just use helpers.
    #
    # That probably wasn't convincing, so let's look at another case in which
    # helpers make things better. Let's say you have an action that renders a
    # form, and in that form you have a dropdown menu. In order to populate this
    # dropdown menu, you have to call some sort of model method to do some sort of
    # query. Where do you store the data you'll feed to the dropdown? "Well, in an
    # instance variable in your controller, of course," you say. "I mean, that's
    # simple, and easy."
    #
    # Okay, but then one day your boss says, "We need to be able to update the
    # entire form via Ajax when you click on this doohickey over here." It's the
    # same view, just a different action. So now you've extracted the form to a
    # partial, and you've added a separate action that's called via Ajax and
    # renders that partial. No biggie.
    #
    # Oh, except that upon hitting this new action, you have to call the same
    # model method to do the same query to ensure that your dropdown is populated.
    # Hmm. "No worries," you say, "I'll just copy that line from the previous
    # action to the new action."
    #
    # That's fine --- for one form element. Now imagine that you have a host of
    # form elements that each require some sort of query to populate. "No
    # worries," you say, "I'll just add a before_filter."
    #
    # But is what you've done really a good solution? I say no.
    #
    # This is where helpers fit perfectly. What if, instead of setting instance
    # variables in your controller which you access in your view, you replaced
    # them with private controller methods, with corresponding helper methods?
    # That way you can access them in your controller and your views. "Okay,
    # sure," you say. "What about the query I'm doing? I don't want to call that
    # twice." Right. That's why you memoize the return value, that way it will be
    # returned for subsequent calls.
    #
    # So this module provides an `expose` method that lets you do just this.
    #
    module LimitedExposure
    
      # Extending a module with LimitedExposure also includes the {Let} module.
      #
      def self.extended(base)
        base.send(:include, ProjectXenon::Let)
      end
  
      # Creates a protected, memoized method in your controller using the given
      # block as the body of the method, and then creates a helper method that
      # points back to the controller method.
      #
      # If you pass multiple names, everything after the first name are aliases
      # to the first method.
      #
      # If you pass `:writer => true` at the end, writer methods for the given
      # method names will also be created which allow you to set the memoized
      # value explicitly.
      #
      # You may also call #expose with no block, in which case the reader method
      # is created with an empty body. The writer method (if specified) will
      # still be created as normal, so you can set the value later if you wish.
      #
      # The #let method from the {Let} module does most of the work here, so read
      # that for some examples.
      #
      def expose(*args, &block)
        names = args.dup
        options = names.extract_options!
        let(*args, &block)
        helper_method *names
      end
      
    end  # module LimitedExposure
  end  # module ControllerMixins
end  # module ProjectXenon