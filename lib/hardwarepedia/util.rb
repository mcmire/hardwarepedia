
module Hardwarepedia
  module Util
    extend self

    def cache_key(*parts)
      parts.join('::')
    end
  end
end
