
class Ohm::Model
  def self.find_or_create(attrs)
    find(attrs) || create(attrs)
  end
end

