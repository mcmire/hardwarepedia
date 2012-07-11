
class Base < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks
  include Hardwarepedia::ModelMixins::RequiresFields
  include Ohm::Expiration  # our extension

  def self.first_or_create(opts, attrs={})
    object = find(opts).first
    if object
      logger.debug "Found a #{self} (#{opts.inspect}), saving with #{attrs.inspect}"
      object.update_attributes(attrs)
      object.save
    else
      merged_attrs = opts.merge(attrs)
      logger.debug "Creating a #{self} (#{merged_attrs.inspect})"
      object = create(merged_attrs)
    end
    logger.debug "All attributes: #{object.attributes.inspect}"
    object
  end

  def self.with_or_create(attr, val, attrs={})
    object = with(attr, val)
    if object
      logger.debug "Found a #{self} (#{attr.inspect}, #{val.inspect}), saving with #{attrs.inspect}"
      object.update_attributes(attrs)
      object.save
    else
      merged_attrs = {attr => val}.merge(attrs)
      logger.debug "Creating a #{self} (#{merged_attrs.inspect})"
      object = create(merged_attrs)
    end
    logger.debug "All attributes: #{object.attributes.inspect}"
    object
  end

  def self.delete_all
    all.to_a.each {|o| o.delete }
    nil
  end

  # def self.logger
  #   @logger ||= Logging.logger['Base'].tap do |logger|
  #     logger.add_appenders('stdout')
  #   end
  # end
end
