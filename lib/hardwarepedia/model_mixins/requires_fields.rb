module Hardwarepedia
  module ModelMixins
    module RequiresFields
      extend ActiveSupport::Concern

      module ClassMethods
        def requires_fields(*fields)
          options = fields.extract_options!
          for field in fields
            required_fields[field.to_sym] = options
          end
          unless @_init_requires_fields
            before_save :check_required_fields
            @_init_requires_fields = true
          end
        end
      
        def required_fields
          @_required_fields ||= {}
        end
      end
      
    private
      def check_required_fields
        missing_fields = []
        self.class.required_fields.each do |field, options|
          if (!options[:if] || __send__(options[:if])) && (!options[:unless] || !__send__(options[:unless]))
            missing_fields << field if __send__(field).blank?
          end
        end
        if missing_fields.any?
          raise "The following fields are required: #{missing_fields.to_sentence}.\nRecord: #{inspect}"
        end
      end
      
    end  # module RequiresFields
  end  # module ModelMixins
end  # module Hardwarepedia