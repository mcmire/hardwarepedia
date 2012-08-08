
module Hardwarepedia
  class ThreadedBatchProcessor < BatchProcessor
    # This is the max number of connections we can make to Postgres
    # TODO: See if we can raise this somehow
    NUM_THREADS = 10

    attr_reader :threads

    def initialize(obj, collection, process_item_method)
      super
      @threads = []
      @thread_count = 0
    end

    def call
      @collection.each_slice(NUM_THREADS) do |chunk|
        @threads.clear
        chunk.each do |item|
          @threads << Thread.new do
            @thread_count += 1
            Thread.current[:name] = "T#{@thread_count}"
            begin
              _process_item(item)
            rescue Exception => e
              logger.error "#{e.class}: #{e.message}"
              (@threads - [Thread.current]).each {|t| t.kill }
              raise e
            end
          end
        end
        t = Time.now
        @threads.each {|t| t.join }
        elapsed_time = Time.now - t
        logger.debug("Finished #{NUM_THREADS} threads in %f seconds (%.1f t/s)" % [elapsed_time, (NUM_THREADS.to_f / elapsed_time)])
      end
    end
  end
end
