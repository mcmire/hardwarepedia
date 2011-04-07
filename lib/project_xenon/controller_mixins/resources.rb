module ProjectXenon
  module ControllerMixins
    module Resources
      
    private
      # Given a `name` and a `block`, creates a memoized method called "#{name}"
      # (aliased to :collection) using `block` as the method's body. A writer
      # method "#{name}=" (aliased to :collection=) will also be provided that
      # overrides the memoization value.
      #
      # (Please see {LimitedExposure} for more information on how this works.)
      #
      # == Example
      # 
      #     class FooController
      #       collection(:foo) { Foo.all }
      #       
      #       def some_action
      #         foo          #=> Foo.all
      #         collection   #=> (same thing)
      #
      #         self.foo = Foo.bar.all
      #         foo          #=> Foo.bar.all
      #         collection   #=> (same thing)
      #       end
      #     end
      #
      def collection(name, &block)
        expose(name, :collection, :writer => true, &block)
      end

      # Given a `name` and a `block`, creates a memoized method called "#{name}"
      # (aliased to :resource) using `block` as the method's body. A writer
      # method "#{name}=" (aliased to :resource=) will also be provided that
      # overrides the memoization value.
      #
      # (Please see {LimitedExposure} for more information on how this works.)
      #
      # == Example
      #
      #     class FooController
      #       resource(:foo) { Foo.find(1) }
      #       
      #       def some_action
      #         foo        #=> Foo.find(1)
      #         resource   #=> (same thing)
      #
      #         self.foo = Foo.bar.find(1)
      #         foo        #=> Foo.bar.find(1)
      #         resource   #=> (same thing)
      #       end
      #     end
      #
      def resource(name, &block)
        expose(name, :resource, :writer => true, &block)
      end
      
    end  # module Resources
  end  # module ControllerMixins
end  # module ProjectXenon