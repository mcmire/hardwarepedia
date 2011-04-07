require File.expand_path('../../lib/require_profiler', __FILE__)
RequireProfiler.start

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
ProjectXenon::Application.initialize!

RequireProfiler.stop