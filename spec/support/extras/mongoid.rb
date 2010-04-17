Rspec.configure do |config|
  config.before :suite do
    Mongoid.master.collections.each(&:drop)
  end
  config.after :suite do
    Mongoid.master.collections.each(&:drop)
  end
end