
class Presenter
  class << self
    def wrap(duck, models)
      models.map {|model| new(duck, model) }
    end

    def model_class_name
      @model_class_name = self.to_s.sub(/Presenter$/, "")
    end

    def model_class
      @model_class ||= model_class_name.constantize
    end

    # Hack to make forms happy
    def human_attribute_name(attribute, options={})
      model_class.human_attribute_name(attribute, options)
    end
  end

  attr_reader :view, :controller, :model

  def initialize(duck, model)
    if Presenter === duck
      @controller = duck.controller
      @view = duck.view
    elsif duck.respond_to?(:view_context)
      @controller = duck
      @view = @controller.view_context
    else
      @view = duck
      @controller = duck.controller
    end
    @model = model

    model_name = self.class.model_class_name.underscore
    singleton_class.__send__(:define_method, model_name) { model }
  end

  def to_param
    @model.id.to_s
  end

  def to_model
    @model
  end

  # Forward missing methods to the model object. This saves you from having to
  # delegate methods yourself.
  def method_missing(name, *args, &block)
    if name != 'object_id' && @model.respond_to?(name)
      @model.__send__(name, *args, &block)
    else
      super
    end
  end

  def respond_to?(name)
    @model.respond_to?(name) || super
  end
end

