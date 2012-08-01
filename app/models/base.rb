
module Base
  extend ActiveSupport::Concern

  included do
    plugin :serialization
    plugin :validation_helpers
    plugin :timestamps, :update_on_create => true
  end

  module ClassMethods
    def first_or_create_by(opts, attrs={})
      indexed_columns = db.indexes(table_name).values.map {|hash| hash[:columns] }.flatten.uniq
      Hardwarepedia::Workspace.mutex(self, *indexed_columns) do
        _first_or_create_by(opts, attrs)
      end
    end

    def _first_or_create_by(conds, attrs={})
      if object = first(conds)
        logger.debug "Found a #{self} (#{conds.inspect}), saving with #{attrs.inspect}"
        object.set(attrs)
        # logger.debug "All attributes: #{object.values.inspect}"
      else
        merged_attrs = conds.merge(attrs)
        logger.debug "Creating a #{self} (#{merged_attrs.inspect})"
        object = new(merged_attrs)
      end
      object.save
      return object
    end

    # Delete all the records in this table without running any hooks.
    #
    def delete_all
      dataset.delete
    end

    # Provide a method that makes a transaction, but then also locks the table.
    # This ensures that if there is another thread trying to access or write to
    # the table right now, it is blocked until the lock is released.
    #
    # You should use this only if your block is doing a small amount of
    # operations, such as a find and a save. Your block should take a short amount
    # of time to execute; if not, think of another solution.
    #
    def transaction_with_lock
      db.transaction do |conn|
        db.run("LOCK TABLE #{table_name}")
        yield
      end
    end
  end
end
