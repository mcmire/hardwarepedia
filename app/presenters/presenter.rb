
class Presenter
  module Base
    def view
      @view ||= Hardwarepedia::ViewContext.current
    end
  end

  class << self
    attr_accessor :mixins

    def inherited(subclass)
      subclass.mixins = mixins.dup
    end

    def define(&block)
      Class.new(self).tap do |klass|
        klass.mixins << Module.new(&block)
      end
    end

    def present!(model_or_models, &block)
      case model_or_models
      when Array, ActiveRecord::Relation, ActiveRecord::Associations::CollectionProxy
        models = model_or_models.to_a
        models.each {|model| _present_model!(model) }
        models
      else
        model = model_or_models
        _present_model!(model)
        model
      end
    end

    def _present_model!(model)
      unless model.respond_to?(:to_model)
        ppl :model => model
        raise 'model is not a model?!'
      end
      mixins.each do |mixin|
        model.extend(mixin)
      end
      ppl :class => model.class,
          :methods => model.methods.any? {|m| m == :linked_chipset }
    end
  end

  self.mixins = [Base]
end
