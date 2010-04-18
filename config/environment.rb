require File.expand_path(File.dirname(__FILE__) + '/../lib/require_profiler')
RequireProfiler.start

# Load the rails application
puts "Loading Rails, please wait..."
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Riggifier::Application.initialize!

RequireProfiler.stop