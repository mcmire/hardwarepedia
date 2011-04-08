require 'database_truncation'
require 'database_seeding'

Rspec.configuration.before do
  Hardwarepedia.truncate_database(:all => true, :silent => true)
  Hardwarepedia.seed_database(:silent => true)
end