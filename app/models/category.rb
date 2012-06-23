
class Category
  def self.find_or_create(name)
    new(name).tap {|c| c.load_or_save! }
  end

  def self.key_for(name)
    Hardwarepedia::Util.key(self, name)
  end

  def self.db
    Hardwarepedia.redis
  end

  attr_accessor :name, :webkey, :state

  def initialize(name, opts={})
    self.name = name
    self.webkey = opts[:webkey] || name.parameterize
    self.state = opts[:state] || 0
  end

  def load_or_save!
    load! or save
    return nil
  end

  def load!
    data = db.hgetall(primary_key)
    if hash.blank?
      return false
    else
      self.webkey = hash['webkey']
      self.state = Integer.from_store(hash['state'])
      return true
    end
  end

  def save
    raise "Cannot save Url: webkey is missing" unless webkey
    raise "Cannot save Url: state is missing" unless state
    hash = {
      'webkey' => webkey,
      'state' => Integer.to_store(hash['state'])
    }
    db.hmset(primary_key, *hash.to_a)
  end

  def primary_key
    self.class.key_for(name)
  end

  def db
    self.class.db
  end
end

