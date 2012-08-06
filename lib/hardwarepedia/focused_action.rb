
require 'forwardable'

module Hardwarepedia

  class FocusedAction
    class << self
      extend Forwardable
      def_delegators :controller_class, :hide_action

      attr_accessor :controller_class

      def for(controller_class, &block)
        # Each action is in fact a subclass of Action
        Class.new(self).tap do |klass|
          klass.controller_class = controller_class
          klass.class_eval(&block)
        end
      end

      # Re-define this instead of merely delegating to controller because we
      # need the helper method to call back to the action, not the
      # controller.
      def helper_method(*meths)
        action_class = self

        meths.flatten!
        controller_class._helper_methods += meths

        meths.each do |meth|
          controller_class._helpers.send(:define_method, meth) do |*args, &blk|
            controller.current_action.__send__(meth, *args, &blk)
          end
        end
      end

      def inspect
        "Hardwarepedia::FocusedAction(#{controller_class})"
      end
    end

    include Hardwarepedia::LimitedExposure

    attr_reader :controller

    extend Forwardable
    def_delegators :controller,
      :params, :session, :flash, :render, :respond_to, :not_found!

    def initialize(controller, name)
      @controller = controller
      @name = name
    end

    def call
      raise NotImplementedError, "You must have a #call action in your def_action block"
    end

    def inspect
      '#<%s %s>' % [self.class.inspect, @name]
    end
  end

end

