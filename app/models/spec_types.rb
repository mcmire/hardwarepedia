class SpecTypes
  class Base
    def compare(a, b)
      a <=> b
    end
  end
  
  class << self
    def register_type(name, &block)
      types[name] = Class.new(Base).new
    end
    
    def types
      @@types ||= {}
    end
    
    def compare(name, a, b)
      type = @@types[name] or raise ArgumentError, "Couldn't find type '#{name}'!"
      type.compare(a, b)
    end
  end
  
  register_type :Hertz do
    def clean(value)
      value.downcase.gsub(/[KMG]hz$/, "").to_i
    end
  end
end