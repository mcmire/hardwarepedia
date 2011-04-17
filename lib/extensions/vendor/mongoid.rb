# https://github.com/mongoid/mongoid/pull/845
module Mongoid
  module Callbacks
    def run_callbacks(kind, *args, &block)
      _run_callbacks_with_cascade(_cascade_targets(kind), kind, *args) do
        super(kind, *args, &block)
      end
    end
    
    protected
    
    def _cascade_targets(kind)
      cascadable_children = []
      self.relations.each_pair do |name, metadata|
        next unless metadata.embedded? && metadata.cascade_callbacks
    
        target = self.send(name)
    
        if metadata.macro == :embeds_many
          cascadable_children += target
        elsif metadata.macro == :embeds_one && target.present?
          cascadable_children << target
        end
      end
      cascadable_children.select { |child| _should_cascade(kind, child) }
    end
    
    def _should_cascade(kind, child)
      [:create, :destroy].include?(kind) || child.changed? || child.new_record?
    end
    
    def _normalize_callback_kind(original_kind, child)
      if original_kind == :update && child.new_record?
        :create
      else
        original_kind
      end
    end
    
    def _run_callbacks_with_cascade(children, kind, *args, &block)
      if child = children.pop
        _run_callbacks_with_cascade(children, kind, *args) do
          kind = _normalize_callback_kind(kind, child)
          child.run_callbacks(kind, *args) do
            block.call
          end
        end
      else
        block.call
      end
    end
  end
end