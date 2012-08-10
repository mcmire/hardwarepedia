
module Hardwarepedia
  module Worker
    def self.redis_key
      @redis_key ||= Nest.new(self, redis)
    end

    def self.redis
      Hardwarepedia.redis
    end

    def self.scraper
      Hardwarepedia.scraper
    end

    attr_accessor :redis

    def redis_key
      @redis_key ||= Nest.new(self, redis)
    end

    def scraper
      Hardwarepedia.scraper
    end
  end
end
