module Hardwarepedia
  module ViewMixins
    module TaggedBody
      
      def current_layout
        controller.send(:_layout)
      end

      # Let's say we have a controller Admin::FooController < Admin::BarController < Admin::BaseController < ApplicationController
      # Then this method will return: ["admin", "admin_foo", "admin_bar", "admin_base", "application"]
      #
      def controller_namespaces
        @controller_namespaces ||=
          controller.class.ancestors.
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

      def tagged_body_start
        id = "act-#{action_name}"
        classes = controller_namespaces.map {|namespace| "clr-#{namespace}" }
        classes << "lyt-#{current_layout}"
        classes << "env-#{Rails.env.to_s.downcase}"
        body_tags = {
          :id => id,
          :classes => classes
        }
        body_tags[:id] = custom_body_tags[:id] if custom_body_tags[:id]
        body_tags[:classes] += custom_body_tags[:classes]
        raw %|<body class="#{body_tags[:classes].join(" ")}" id="#{body_tags[:id]}">|
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
  end  # module ViewMixins
end  # module Hardwarepedia