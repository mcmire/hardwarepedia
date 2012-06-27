
module Ohm
  module Expiration
    extend ActiveSupport::Concern

    module ClassMethods
      def expire_in(ttl)
        @ttl = ttl
      end

      def ttl
        @ttl
      end
    end

    include Ohm::Callbacks

    def after_save
      super
      Ohm.redis.expire(key, self.class.ttl)
      Ohm.redis.expire("#{key}:_indices", self.class.ttl)
    end
  end
end
