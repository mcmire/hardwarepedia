class Module
  def boolean_attr(*names)
    Array.wrap(names).each do |name|
      attr_accessor name
      alias_method :"#{name}?", name
      define_method(:"#{name}!") { __send__(:"#{name}=", true) }
    end
  end
end