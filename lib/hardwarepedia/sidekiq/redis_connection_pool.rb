
module Hardwarepedia
  module Sidekiq
    class RedisConnectionPool
      def call(worker, msg, queue)
        Hardwarepedia.redis_pool.with_connection do |redis|
          worker.redis = redis
          yield
        end
      end
    end
  end
end
