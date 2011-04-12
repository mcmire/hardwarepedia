module Hardwarepedia
  module ModelMixins
    module RequiresFields
      extend ActiveSupport::Concern

      module ClassMethods
        def requires_fields(*fields)
          required_fields.merge fields.map(&:to_sym)
          unless @_init_requires_fields
            before_save :check_required_fields
            @_init_requires_fields = true
          end
        end
      
        def required_fields
          @_required_fields ||= Set.new
        end
      end
      
    private
      def check_required_fields
        missing_fields = self.class.required_fields.select {|field| __send__(field).blank? }
        if missing_fields.any?
          raise "The following fields are required: #{missing_fields.to_sentence}"
        end
      end
      
    end  # module RequiresFields
  end  # module ModelMixins
end  # module Hardwarepedia