
module Hardwarepedia
  class << self
    attr_accessor :redis
    attr_accessor :redis_pool
    attr_writer :use_threads
    def use_threads?; @use_threads; end
  end

  NUM_CONCURRENT_WORKERS = 10
  self.use_threads = true

  def self.init
    redis = Redis.new
    self.redis = redis
    self.redis_pool = ConnectionPool.new(:size => 10, :timeout => 3) { Redis.new }
  end

  def self.queue(klass, *args)
    if use_threads?
      klass.perform_async(*args)
    else
      klass.new.perform(*args)
    end
  end
end
