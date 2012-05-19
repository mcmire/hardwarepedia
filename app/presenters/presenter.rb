
# The "world's simplest presenter pattern".
# Courtesy: https://gist.github.com/1888244
#
module Presenter
  def self.for(model, &block)
    Class.new(model) do
      presenter = self

      singleton_define_method(:model_name) { model.model_name }

      if model.respond_to?(:table_name)
        presenter.set_table_name(model.table_name)
      end

      if model.respond_to?(:base_class)
        singleton_define_method(:base_class) { model.base_class }
      end

      if model.respond_to?(:collection_name)
        presenter.collection_name = model.collection_name
      end

      if model.respond_to?(:hereditary?)
        singleton_define_method(:hereditary?) { false }
        define_method(:hereditary?) { self.class.hereditary? }
      end

      define_method(:helper) { @helper ||= Helper.new } if defined?(Helper)
      alias h helper

      presenter.class_eval(&block) if block

      presenter
    end
  end
end
