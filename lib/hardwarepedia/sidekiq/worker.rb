
module Hardwarepedia
  module Sidekiq
    module Worker
      # Provide the following methods as both instance AND class methods.
      # The instance variables will remain local to their context -- that is, the
      # connection to redis does not propagate from class to instance, there are
      # two separate connections created.
      # extend self

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

      def self.included(base)
        base.class_eval do
          attr_accessor :current_ourl, :current_doc
        end
      end

      def scraper
        Hardwarepedia.scraper
      end

      def slogger
        scraper.logger
      end

      def visiting(page_config, url, resource=nil)
        scraper.visiting(page_config, url, resource) do |ourl, doc|
          @current_ourl = ourl
          @current_doc = doc
          yield
        end
      end
    end
  end
end
