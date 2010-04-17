#puts "spec/spec_helper.rb loaded, from:"
#puts caller
#puts

$SPEC_HELPER_LOADED = true

$start_time = Time.now

#require 'rubygems'
#require 'spork'

def hputs(str="")
  str << "\n" unless str[-1] == ?\n
  print str.gsub(/\n/, "<br />\n")
end
def hprintf(*args)
  args[0].gsub!(/\n/, "<br />\n")
  printf(*args)
end

#class MissingSourceFile < LoadError; end

#Spork.prefork do
  time = Time.now
  
  # Ugh. Faggot
  I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2 = true
  
  ENV["RAILS_ENV"] = "test"
  require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

  # Go ahead and require ApplicationController since Spork delays loading it until each_run.
  # I think Rails think it's already been loaded at this point, but anyway, when rspec-rails
  # loads below, ActionController::IntegrationTest doesn't link up to the proper ApplicationController.
  # Also, for some reason ApplicationController is never getting reloaded when we run acceptance tests,
  # so when the tests are actually run, everything in our ApplicationController is simply ignored.
  # I don't think this is specific to Rails 2.3.x, but I could be wrong
  # (maybe the internals of integration testing changed in 2.3.x or something).
  #load "#{RAILS_ROOT}/app/controllers/application_controller.rb"
  #load "#{RAILS_ROOT}/app/helpers/application_helper.rb"
  
  #require 'rspec/rails'
  require 'rspec'
  
  Rspec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    #config.mock_with :rspec

    # If you'd prefer not to run each of your examples within a transaction,
    # uncomment the following line.
    # config.use_transactional_examples false
  end
  
  

  #hprintf "Time for prefork: %.4f s\n", (Time.now.to_f - time.to_f)
#end

#Spork.each_run do
  time = Time.now
  
  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories.
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f }
  
  #hprintf "Time for each_run: %.4f s\n", (Time.now.to_f - time.to_f)
#end

#hputs
#hprintf "Time to load spec_helper: %.4f s\n", (Time.now.to_f - $start_time.to_f)