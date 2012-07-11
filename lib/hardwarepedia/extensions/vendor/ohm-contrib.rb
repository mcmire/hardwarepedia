
module Ohm
  module DataTypes
    module Type
      Set = lambda { |s| s && (String === s ? SerializedSet.from_store(s) : s) }

      class SerializedSet < ::Set
        def self.from_store(str)
          new(JSON.parse(str))
        end

        def to_s
          JSON.generate(to_a)
        end
      end
    end
  end
end
