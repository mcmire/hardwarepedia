
require 'monitor'

module Hardwarepedia
  module Workspace
    extend MonitorMixin

    class << self
      def locks
        @locks ||= {}
      end

      def queues
        @queues ||= {}
      end

      def mutex(klass, *keys, &block)
        key = [klass] + keys
        wait_for(key) if lock_for(key)
        lock(key, &block)
      end

      def lock_for(key)
        # if two threads read this at the exact same time, then both may read
        # that a lock is available
        synchronize do
          locks[key]
        end
      end

      def lock(key)
        # if two threads lock at the exact same time, well, that's silly
        synchronize do
          begin
            # logger.debug "Lock reserve: #{key.inspect}"
            locks[key] = Thread.current
            yield
          ensure
            # logger.debug "Lock release: #{key.inspect}"
            locks.delete(key)
            notify(key)
          end
        end
      end

      def wait_for(key)
        # logger.debug "Lock wait: #{key.inspect}"
        queue = queues[key] ||= []
        cond = new_cond
        queue << cond
        # put this thread to sleep, we will wake it up when there is an opening
        cond.wait_while { lock_for(key) }
      end

      def notify(key)
        if queue = queues[key]
          # do not notify all in line, just the first one - after he finishes
          # then he will call notify() again
          cond = queue.unshift
          cond.signal
        end
      end

      def check_locks
        if locks.any?
          raise "Not all locks were executed"
        end
        if queues.any? {|key, queue| queue.any? }
          raise "People are still in line"
        end
      end
    end
  end
end

at_exit { Hardwarepedia::Workspace.check_locks }

