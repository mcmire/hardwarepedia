
class Base < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks
  include Hardwarepedia::ModelMixins::RequiresFields
  include Ohm::Expiration  # our extension

  def self.transaction(&block)
    Ohm::Transaction.new(&block).tap {|t| t.commit(db) }
  end

  # def self.queued_transaction(&block)
  #   Transaction.new(&block)
  # end

  def self.first_or_create(opts, attrs={})
    object = nil
    save_txn = nil

    transaction do |t|
      t.watch(key)

      t.read do
        object = find(opts).first
        if object
          logger.debug "Found a #{self} (#{opts.inspect}), saving with #{attrs.inspect}"
          object.update_attributes(attrs)
        else
          merged_attrs = opts.merge(attrs)
          logger.debug "Creating a #{self} (#{merged_attrs.inspect})"
          object = new(merged_attrs)
        end
      end
    end

    # this has to happen outside of the previous transaction because it has its
    # own watch's and write's and so on
    object.save

    logger.debug "All attributes: #{object.attributes.inspect}"
    return object
  end

  def self.with_or_create(attr, val, attrs={})
    object = nil
    save_txn = nil

    transaction do |t|
      t.watch(key)

      t.read do
        object = with(attr, val)
        if object
          logger.debug "Found a #{self} (#{attr.inspect}, #{val.inspect}), saving with #{attrs.inspect}"
          object.update_attributes(attrs)
        else
          merged_attrs = {attr => val}.merge(attrs)
          logger.debug "Creating a #{self} (#{merged_attrs.inspect})"
          object = new(merged_attrs)
        end
      end
    end

    # this has to happen outside of the previous transaction because it has its
    # own watch's and write's and so on
    object.save

    logger.debug "All attributes: #{object.attributes.inspect}"
    return object
  end

  def self.delete_all
    all.to_a.each {|o| o.delete }
    return nil
  end

  # def self.logger
  #   @logger ||= Logging.logger['Base'].tap do |logger|
  #     logger.add_appenders('stdout')
  #   end
  # end

  def transaction(&block)
    self.class.transaction(&block)
  end

  # def queued_transaction(&block)
  #   self.class.queued_transaction(&block)
  # end

  def save!
    t = _queue_save
    t.commit(db)
    return self
  end

  def _queue_save
    transaction do |t|
      t.watch(*_unique_keys)

      if not new?
        t.watch(key)
        t.watch(key[:_indices]) if model.indices.any?
        t.watch(key[:_uniques]) if model.uniques.any?
      end

      t.before do
        _initialize_id if new?
      end

      _uniques = nil
      uniques  = nil
      _indices = nil
      indices  = nil

      t.read do
        _verify_uniques
        _uniques = db.hgetall(key[:_uniques])
        _indices = db.smembers(key[:_indices])
        uniques  = _read_index_type(:uniques)
        indices  = _read_index_type(:indices)
      end

      t.write do
        db.sadd(model.key[:all], id)
        _delete_uniques(_uniques) if _uniques
        _delete_indices(_indices) if _indices
        _save
        _save_indices(indices)
        _save_uniques(uniques)
      end
    end
  end

  def delete
    t = _queue_delete
    t.commit(db)
  end

  def _queue_delete
    transaction do |t|
      _uniques = nil
      _indices = nil

      t.watch(*_unique_keys)

      t.watch(key)
      t.watch(key[:_indices]) if model.indices.any?
      t.watch(key[:_uniques]) if model.uniques.any?

      t.read do
        _uniques = db.hgetall(key[:_uniques])
        _indices = db.smembers(key[:_indices])
      end

      t.write do
        _delete_uniques(_uniques) if _uniques
        _delete_indices(_indices) if _indices
        model.collections.each { |e| db.del(key[e]) }
        db.srem(model.key[:all], id)
        db.del(key[:counters])
        db.del(key)
      end

      yield t if block_given?
    end
  end

  def update(attributes)
    t = _queue_update(attributes)
    t.commit(db)
  end

  def _queue_update(attributes)
    update_attributes(attributes)
    _queue_save
  end

   def _delete_indices(_indices)
     model.indices.each do |att|
       val = __send__(att)
       db.srem(model.key[:indices][att][val], id)
     end

     _indices.each do |index|
       db.srem(index, id)
       db.srem(key[:_indices], index)
     end
   end
end
