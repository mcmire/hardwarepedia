
module Hardwarepedia
  module ViewMixins
    module TaggedBody

      def tagged_body_start
        id = "act-#{action_name}"
        body_tags = {
          :id => id,
          :classes => _body_classes
        }
        body_tags[:id] = custom_body_tags[:id] if custom_body_tags[:id]
        body_tags[:classes] += custom_body_tags[:classes]
        # can't use content_tag here since it prints out the end tag, boo
        raw %|<body class="#{body_tags[:classes].join(" ")}" id="#{body_tags[:id]}">|
      end

      def _body_classes
        controller.controller_namespaces.map {|namespace| "clr-#{namespace}" }.tap do |classes|
          classes << "lyt-#{controller.current_layout}"
          classes << "env-#{Rails.env.to_s.downcase}"
        end
      end

    end
  end
end
