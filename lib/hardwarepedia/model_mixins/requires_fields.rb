
require 'ohm/callbacks'

module Hardwarepedia
  module ModelMixins
    module RequiresFields

      extend ActiveSupport::Concern

      module ClassMethods
        def requires_fields(*fields)
          options = fields.extract_options!
          for field in fields
            before_save_checks << [
              "#{field} is required",
              lambda { |model|
                (!options[:if] || model.__send__(options[:if])) &&
                (!options[:unless] || !model.__send__(options[:unless])) &&
                model.__send__(field).blank?
              }
            ]
          end
        end

        def fails_save_with(msg, &blk)
          before_save_checks << [msg, blk]
        end

        def before_save_checks
          @before_save_checks ||= []
        end
      end

      include Ohm::Callbacks

      def before_save
        super
        error_messages = []
        self.class.before_save_checks.each do |msg, check|
          if check.call(self)
            error_messages << msg
          end
        end
        if error_messages.any?
          raise "Save failed! #{error_messages.join(", ")}.\nRecord: #{inspect}"
        end
      end

    end  # module RequiresFields
  end  # module ModelMixins
end  # module Hardwarepedia
