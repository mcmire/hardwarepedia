require 'database_truncation'
require 'database_seeding'

Rspec.configuration.before do
  Riggifier.truncate_database(:all => true, :silent => true)
  Riggifier.seed_database(:silent => true)
end