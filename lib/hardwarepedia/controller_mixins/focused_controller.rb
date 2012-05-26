
module Hardwarepedia
  module ControllerMixins

    module FocusedController
      extend ActiveSupport::Concern

      included do
        attr_reader :current_action
      end

      module ClassMethods
        def def_action(name, &block)
          action_class = Hardwarepedia::FocusedAction.for(self, &block)
          define_method(name) do
            action = action_class.new(self, name)
            @current_action = action
            action.call
          end
        end
      end
    end

  end
end
