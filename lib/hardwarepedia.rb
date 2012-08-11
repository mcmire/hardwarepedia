
module Hardwarepedia
  class << self
    attr_accessor :num_concurrent_workers
    attr_writer :use_threads
    def use_threads?; @use_threads; end
  end

  # TODO : Move these to Loquacious-land
  self.num_concurrent_workers = 25  #10
  self.use_threads = true

  def self.init
  end

  def self.redis(&block)
    Sidekiq.redis(&block)
  end

  def self.queue(klass, *args)
    if use_threads?
      klass.perform_async(*args)
    else
      klass.new.perform(*args)
    end
  end
end
