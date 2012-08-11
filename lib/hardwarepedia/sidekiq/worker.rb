
module Hardwarepedia
  module Sidekiq
    module Worker
      # Provide the following methods as both instance AND class methods.
      # The instance variables will remain local to their context -- that is, the
      # connection to redis does not propagate from class to instance, there are
      # two separate connections created.
      extend self

      # def redis_key
      #   @redis_key ||= Nest.new(self, redis)
      # end

      # def redis(&block)
      #   if block
      #     Hardwarepedia.redis do |conn|
      #       @redis = conn
      #       block.call(conn)
      #     end
      #   else
      #     @redis
      #   end
      # end

      def scraper
        Hardwarepedia.scraper
      end

      def self.included(base)
        base.class_eval do
          include ::Sidekiq::Worker
          sidekiq_options :retry => false
        end
      end
    end
  end
end
