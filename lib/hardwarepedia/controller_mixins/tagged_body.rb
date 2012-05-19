
module Hardwarepedia
  module ControllerMixins
    module TaggedBody
      extend ActiveSupport::Concern

      included do
        hide_action :current_layout, :controller_namespaces,
                    :tag_body, :custom_body_tags
        helper_method :current_layout, :custom_body_tags
      end

      module ClassMethods
        def tag_body(opts={})
          before_filter {|c| c.send(:tag_body, opts) }
        end
      end

      def current_layout
        _layout
      end

      # Let's say we have the following controller hierarchy:
      #
      #   ApplicationController
      #   > Admin::BaseController
      #     > Admin::BarController
      #       > Admin::FooController
      #
      # Then, for Admin::FooController, this method will return:
      #
      #   ["admin", "admin_foo", "admin_bar", "admin_base", "application"]
      #
      def controller_namespaces
        @_controller_namespaces ||=
          self.class.ancestors.
            select {|klass| klass < ActionController::Base }.
            map {|klass|
              klass.to_s.
              sub(/Controller$/, "").
              split("::").
              # maybe a more efficient way to do this?
              inject([]) {|a,k| a << (a + [k.underscore]).join("_"); a }
            }.
            flatten.
            uniq
      end

      def tag_body(opts={})
        if opts[:class]
          custom_body_tags[:classes] << opts[:class]
        else
          custom_body_tags[:id] = opts[:id]
        end
      end

      def custom_body_tags
        @_custom_body_tags ||= {:id => nil, :classes => []}
      end

    end  # module TaggedBody
  end  # module ControllerMixins
end  # module Hardwarepedia

