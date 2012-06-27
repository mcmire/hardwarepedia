
module Ohm
  module DataTypes
    module Type
      Set = lambda { |s| s && SerializedSet.from_store(s) }

      class SerializedSet < ::Set
        def self.from_store(str)
          JSON.parse(str)
        end

        def to_s
          JSON.generate(self)
        end
      end
    end
  end
end
