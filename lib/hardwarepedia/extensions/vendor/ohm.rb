
class Ohm::Model
  def self.first_or_create(opts, attrs)
    object = find(method, opts).first
    if object
      object.update_attributes(attrs)
      object.save
    else
      create(attrs.merge(opts))
    end
  end

  def self.with_or_create(opts, attrs)
    object = with(method, opts)
    if object
      object.update_attributes(attrs)
      object.save
    else
      create(attrs.merge(opts))
    end
  end
end

