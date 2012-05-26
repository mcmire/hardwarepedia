
module Hardwarepedia
  module ControllerMixins
    module ViewContextFilter
      def self.included(controller)
        controller.send(:before_filter, :_set_current_view_context)
      end

      def _set_current_view_context
        ViewContext.current = self.view_context
      end
    end
  end
end
