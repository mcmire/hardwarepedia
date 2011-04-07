module ProjectXenon
  # This module provides a method, `let`, which further encapsulates making a
  # memoized method.
  #
  # Use it like so:
  #
  #     class SomeClass
  #       include Let
  #       let(:one) { some_return_value }
  #     end
  #
  # Now when we call `one` in a method of SomeClass, we will get the return value
  # of the block. This return value, by the way, is cached, or "memoized", so
  # future calls just hit the cached value. This is in case the block content is
  # something like a query.
  #
  module Let
    extend ActiveSupport::Concern

  private
    def __memoized
      @__memoized ||= {}
    end
  
    module ClassMethods
      # Defines a protected instance method by the given `name`. This method
      # will execute the given `block`, and then memoize the return value of the
      # block for subsequent calls.
      #
      # If you pass multiple `names`, everything after the first name is an
      # alias to the first method.
      #
      # If you pass `:writer => true` at the end, writer methods for the given
      # method names will also be created which allow you to set the return
      # value of the reader method explicitly (actually the memoized value is
      # overwritten).
      #
      # You may also call #let with no block, in which case the reader method
      # is created with an empty body. The writer method (if specified) will
      # still be created as normal, so you can set the value later if you wish.
      #
      # == Examples
      #
      # Here we define a value called "foo":
      #
      #     class SomeClass
      #       include Let
      #       
      #       let(:foo) { some_expensive_operation }
      #       
      #       def some_method
      #         foo  #=> (result of some_expensive_operation)
      #         foo  #=> (result from the last call)
      #       end
      #     end
      #
      # Here we define a value called "foo", aliased as "bar":
      #
      #     class SomeClass
      #       include Let
      #
      #       let(:foo, :bar) { some_expensive_operation }
      #
      #       def some_method
      #         foo  #=> (result of some_expensive_operation)
      #         foo  #=> (result from the last call)
      #         bar  #=> (same thing)
      #       end
      #     end
      #
      # Here we define a value called "foo" which is initially something but
      # which we overwrite in #some_method:
      #
      #     class SomeClass
      #       include Let
      #
      #       let(:foo, :writer => true) { some_expensive_operation }
      #
      #       def some_method
      #         self.foo = "bar"
      #         foo  #=> "bar"
      #       end
      #     end
      #
      # Finally, here we define a value "foo" which is initially nothing until
      # we set it in #some_method:
      #
      #     class SomeClass
      #       include Let
      #
      #       let(:foo)
      #
      #       def some_method
      #         self.foo = "bar"
      #         foo  #=> "bar"
      #       end
      #     end
      # 
      # == Adapted from:
      #
      # * <http://ruby-lambda.blogspot.com/2010/06/stealing-let-from-rspec.html>
      # * <http://gist.github.com/453389>
      #
      def let(*names, &block)
        options = names.extract_options!
        define_method(names[0]) do
          __memoized[names[0]] ||= (instance_eval(&block) if block)
        end
        # If the primary method is called to cache the return value,
        # the alias methods will also be cached since they just defer to the primary method
        names[1..-1].each {|name| alias_method name, names[0] }
        protected(*names)
        
        if options[:writer]
          define_method("#{names[0]}=") do |value|
            __memoized[names[0]] = value
          end
          # If the primary method is called to cache the return value,
          # the alias methods will also be cached since they just defer to the primary method
          names[1..-1].each {|name| alias_method "#{name}=", "#{names[0]}=" }
        end
      end
      
    end  # module ClassMethods
  end  # module Let
end  # module ProjectXenon