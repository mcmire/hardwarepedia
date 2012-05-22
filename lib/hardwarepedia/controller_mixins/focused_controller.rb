
require 'forwardable'

module Hardwarepedia
  module ControllerMixins
    module FocusedController
      class Action
        class << self
          extend Forwardable
          def_delegators :controller_class,
            :helper_method, :hide_action

          attr_accessor :controller_class

          def for(controller_class, &block)
            # Each action is in fact a subclass of Action
            Class.new(self).tap do |klass|
              klass.controller_class = controller_class
              klass.class_eval(&block)
            end
          end
        end

        include Hardwarepedia::LimitedExposure

        attr_reader :controller

        extend Forwardable
        def_delegators :controller,
          :params, :session, :flash, :respond_to

        def initialize(controller)
          @controller = controller
        end

        def call
          raise NotImplementedError, "You must have a #call action in your def_action block"
        end
      end

      def def_action(name, &block)
        action = Action.for(self, &block)
        define_method(name) { action.new(self).call }
      end

    end
  end
end
