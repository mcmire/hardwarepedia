require File.expand_path('../../lib/require_profiler', __FILE__)
RequireProfiler.start

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Riggifier::Application.initialize!

RequireProfiler.stop