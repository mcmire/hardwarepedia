module ProjectXenon
  module ViewMixins
    module Resources
      
      extend ActiveSupport::Memoizable

      def resource_class
        controller.class.to_s.sub(/Controller$/, "").demodulize.singularize.constantize
      end

      def resource_id
        resource_class.to_s.underscore
      end
      
      def full_resource_id
        controller.class.to_s.sub(/Controller$/, "").underscore.singularize.gsub("/", "_")
      end

      def resource_name
        resource_id.humanize.downcase
      end

      def resource_descriptor
        resource_name.titleize + " " +
        (resource_class.respond_to?(:descriptor_attribute) ?
          "'#{resource.send(resource_class.descriptor_attribute)}'" :
          "##{resource.id}")
      end
      
      def resource_url(resource=self.resource)
        polymorphic_url(resource)
      end

      def collection_id
        resource_class.to_s.tableize
      end

      def collection_name
        collection_id.humanize.downcase
      end

      def new_resource_url
        send("new_#{full_resource_id}_url")
      end

      def viewable_attributes_for_resource
        attributes = resource_class.respond_to?(:viewable_attributes) ?
          resource_class.viewable_attributes.to_a.map(&:to_s) :
          resource_class.new.attribute_names
        attributes - %w(id created_at updated_at)
      end
      memoize :viewable_attributes_for_resource

      def editable_attributes_for_resource
        attributes = resource_class.respond_to?(:editable_attributes) ?
          resource_class.editable_attributes.to_a.map(&:to_s) :
          resource_class.new.attribute_names
        attributes - %w(id created_at updated_at)
      end
      memoize :editable_attributes_for_resource

      def simple_resourceful_form_for(polymorphic_id, options={}, &block)
        resource = (Array === polymorphic_id) ? polymorphic_id.last : polymorphic_id
        options = options.merge(
          :as => full_resource_id,
          # FIXME: This isn't quite right -- needs to include any namespaces
          :url => polymorphic_url(resource)
        )
        simple_form_for(polymorphic_id, options, &block)
      end
      
    end  # module Resources
  end  # module ViewMixins
end  # module ProjectXenon