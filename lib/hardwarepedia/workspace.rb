
require 'thread'

module Hardwarepedia
  module Workspace
    module Mixin
      def mutex(klass, *keys, &block)
        Workspace.mutex(klass, *keys, &block)
      end
    end

    class << self
      def _mutex
        @@mutex ||= Mutex.new
      end

      def locks
        @@locks ||= {}
      end

      def queue_sizes
        @@queue_sizes ||= {}
      end

      def mutex(klass, *keys, &block)
        key = [klass] + keys
        if t = lock_for(key)
          if t == Thread.current
            raise "You have already locked this key: #{key.inspect}"
          end
          wait_for(key) { lock(key, &block) }
        else
          lock(key, &block)
        end
      end

      def lock_for(key)
        _mutex.synchronize { locks[key] }
      end

      def lock(key)
        # FIXME: Seems like the mutex isn't quite working... two threads are
        # attempting to reserve at the exact same time and succeeding?!
        logger.debug "Lock reserve: #{key.inspect} (#{queue_size_for(key)} in queue)"
        locks[key] = Thread.current
        yield
      ensure
        logger.debug "Lock release: #{key.inspect} (#{queue_size_for(key)} in queue)"
        locks.delete(key)
      end

      def wait_for(key)
        increment_queue_for(key)
        logger.debug "Lock wait: #{key.inspect} (#{queue_size_for(key)} in queue)"
        t = Time.now
        expires_after = 2 # seconds
        begin
          if (Time.now - t) > expires_after
            raise "I've been waiting #{expires_after} seconds for #{key.inspect}. I'm giving up."
          end
          sleep 0.2
        end while lock_for(key)
        decrement_queue_for(key)
        yield
      end

      def check_locks
        if locks.any?
          msg = "There are still locks open for these keys:\n"
          locks.each_key do |key|
            msg << " * #{key.inspect}\n"
          end
          raise msg
        end
      end

      def queue_size_for(key)
        queue_sizes[key] ||= 0
      end

      def increment_queue_for(key)
        queue_sizes[key] ||= 0
        queue_sizes[key] += 1
      end

      def decrement_queue_for(key)
        queue_sizes[key] -= 1
      end
    end
  end
end

at_exit { Hardwarepedia::Workspace.check_locks }

