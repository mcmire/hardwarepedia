
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
      enqueue(klass, *args)
    end
  end

  def self.enqueue(klass, *args)
    @queue ||= []
    @queue << [klass, args]
  end

  def self.execute_queue
    @queue.each do |klass, args|
      # begin
        klass.new.perform(*args)
      # rescue => e
      #   puts "ERROR running #{klass}:"
      #   puts "#{e.class}: #{e.message}"
      #   puts e.backtrace.join("\n")
      # end
    end
  end
end

if not Hardwarepedia.use_threads?
  at_exit { Hardwarepedia.execute_queue }
end
