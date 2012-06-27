
class Ohm::Model
  def self.first_or_create(opts, attrs={})
    object = find(opts).first
    if object
      object.update_attributes(attrs)
      object.save
    else
      create(opts.merge(attrs))
    end
  end

  def self.with_or_create(attr, val, attrs={})
    object = with(attr, val)
    if object
      object.update_attributes(attrs)
      object.save
    else
      create({attr => val}.merge(attrs))
    end
  end

  def self.delete_all
    all.each {|o| o.delete }
  end
end

