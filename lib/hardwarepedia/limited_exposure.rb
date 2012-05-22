
module Hardwarepedia
  # This is a module that provides two methods, `expose` and `let`, which
  # allow you to cleanly and clearly define lazily-evaluated, memoized
  # values that you can use anywhere in your controllers and views. It's
  # very similar to the decent_exposure[1] gem, but it works more simply
  # (and doesn't have a default action when you don't pass a block to
  # #expose, to keep things very very simple).
  #
  # You will want to mix this into ApplicationController.
  #
  # == Rationale
  #
  # Oftentimes you will need to share some value between controller actions,
  # or set the value in the controller and propagate it to the view so you
  # can use it there.  The conventional way to solve this is by setting an
  # instance variable in a before filter. However this has some problems:
  #
  # * Rails is magical when it comes to controllers. Instance variables
  #   propagate to views? They propagate to partials too? Really? How does
  #   that work?
  # * Rendering a template that relies on an instance variable whose name
  #   does not match the action name (for instance, rendering 'new' from the
  #   create action) is a pain because you have to remember to include
  #   :create in the before_filter, or call the before_filter manually.
  # * Partials that rely on instance variables are a pain to share between
  #   different controllers because you have to remember to copy over the
  #   before_filters.
  # * If an instance variable set in before_filter A depends on the instance
  #   variable set in before_filter B, you must remember to place
  #   before_filter A *before* B, otherwise your app will break. If you
  #   have a lot of dependencies then this gets pretty hairy.
  #
  # The `expose` method this module provides solves these problems:
  #
  # * `expose` simply makes a (memoized) helper method which the view has
  #   access to. There's no magic involved -- you can figure out how it
  #   works very easily.
  # * Because the value returned by your `expose` is not evaluated until you
  #   request it, you are free to refer to other `expose`d values -- there
  #   is no need for certain `expose`s to be defined before others.
  # * Sharing `expose`d values between controllers is easy -- just stuff
  #   the `expose`s in a module and share it.
  # * Sharing these values between actions is easy too -- you've already
  #   defined them in your controller, so it's dead simple to use them in
  #   any view, including partials -- they're already available.
  # * Having a list of `expose`d values makes your controller more OO -- it
  #   says, "here is a list of values that I as a controller am exposing"
  #   and it lets other developers know what values they are free to use in
  #   views.
  #
  # [1]: http://github.com/voxdolo/decent_exposure
  #
  module LimitedExposure
    extend ActiveSupport::Concern

    module ClassMethods
      # Public: Declare a controller variable which will also be available in
      # views.
      #
      # The variable is implemented as a memoized controller method, and may
      # have an optional value (evaluated at call time). A writer method is
      # also created so the value can be overridden at runtime. A helper
      # method is also created.
      #
      # name    - The Symbol name of the method.
      # block   - Should return the initial value of the variable. When the
      #           method is called, the block will be evaluated and its return
      #           value will be cached. If the block is omitted, the method
      #           and variable return nothing.
      #
      # Example
      #
      #   # === Controller ===
      #
      #   expose(:posts) { Post.all }
      #   expose(:post)
      #   def new
      #     self.post = Post.new
      #   end
      #   def edit
      #     self.post = Post.find(params[:id])
      #   end
      #
      #   # === View ('new' action) ===
      #
      #   <%= posts.inspect %>   <%# "[<Post id: 1, ...>, <Post id: 2, ...>]" %%>
      #   <%= post.persisted? %> <%# false %>
      #
      #   # === View ('edit' action) ===
      #
      #   <%= posts.inspect %>   <%# "[<Post id: 1, ...>, <Post id: 2, ...>]" %>
      #   <%= post.persisted? %> <%# true %>
      #
      def expose(name, options={}, &block)
        let(name, &block)
        helper_method name
        exposed_vars << name.to_sym
      end

      # Public: Declare a memoized controller variable.
      #
      # The variable is implemented as a memoized controller method, and may
      # have an optional value (evaluated at call time). A writer method is
      # also created so the value can be overridden at runtime. No helper
      # method is created.
      #
      # name    - The Symbol name of the method.
      # block   - Should return the initial value of the variable. When the
      #           method is called, the block will be evaluated and its
      #           return value will be cached. If the block is omitted, the
      #           method and variable return nothing.
      #
      # Examples
      #
      #   # 1. Declare a memoized variable with a value
      #   let(:foo) { some_expensive_operation }
      #   def some_action
      #     foo  #=> (result of some_expensive_operation)
      #     foo  #=> (result from the last call)
      #   end
      #
      #   # 2. Declare a memoized variable with a value, then override it
      #   let(:foo) { some_expensive_operation }
      #   def some_action
      #     self.foo = "bar"
      #     foo  #=> "bar"
      #   end
      #
      #   # 3. Declare an undefined variable set in the action
      #   let(:foo)
      #   def some_action
      #     foo  #=> nil
      #     self.foo = "bar"
      #     foo  #=> "bar"
      #   end
      #
      # Inspiration
      #
      # * <http://ruby-lambda.blogspot.com/2010/06/stealing-let-from-rspec.html>
      # * <http://gist.github.com/453389>
      #
      def let(name, options={}, &block)
        name = name.to_sym
        define_method(name) do
          __memoized[name] ||= (instance_eval(&block) if block)
        end
        define_method("#{name}=") do |value|
          __memoized[name] = value
        end

        # Don't make this protected so that we can easily refer to this
        # method in tests
        hide_action name, "#{name}=" if respond_to?(:hide_action)
      end

      def exposed_vars
        @_exposed_vars ||= []
      end
    end

    def __memoized
      @__memoized ||= {}
    end

  end  # module LimitedExposure
end  # module Hardwarepedia

