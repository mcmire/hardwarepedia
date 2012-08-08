
module Hardwarepedia
  class BatchProcessor
    def self.call(*args)
      new(*args).call
    end

    attr_reader :obj, :collection, :process_item_method

    def initialize(obj, collection, process_item_method)
      @obj = obj
      @collection = collection
      @process_item_method = process_item_method
    end

    def call
      @collection.each do |item|
        _process_item(item)
      end
    end

    def _process_item(item)
      @obj.__send__(@process_item_method, item)
    end
  end
end
