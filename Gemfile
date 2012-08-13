
source :rubygems

# gem 'rails', '3.2.3'
gem 'tzinfo', '~> 0.3.29'  # activesupport should be requiring this but it doesn't :(
gem 'activesupport', '3.2.3'
gem 'actionpack', '3.2.3'

gem 'pg', '0.14.0'

gem 'sequel', '3.34.1'
gem 'sequel_pg', '1.3.0', :require => 'sequel'
gem 'sequel_polymorphic', :git => 'https://github.com/saimonmoore/sequel_polymorphic'
# gem 'talentbox-sequel-rails', '0.3.4'
# gem 'mcmire-sequel-rails', :require => 'sequel/rails', :path => '~/code/github/forks/sequel-rails'
gem 'mcmire-sequel-rails', :require => 'sequel/rails', :git => 'http://github.com/mcmire/sequel-rails', :branch => 'mcmire'

gem 'redis', '3.0.1'
gem 'nest', '1.1.1'

gem 'slim', '~> 1.2.0'
gem 'sinatra', '~> 1.3.2', :require => nil
gem 'sidekiq', '2.1.1'

#---

gem 'mustache', '0.99.4'
gem 'stache', '0.9.1'

gem 'logging', '1.7.2'
gem 'logging-rails', '0.4.0'

gem 'multi_json', '1.3.5'
gem 'oj', '1.3.0'

gem 'hierarchical_page_titles', '0.2.0'

# gem 'simple-navigation', '3.7.0'

# Make sure you have libxml-dev and libxslt-dev installed before you install this
gem 'nokogiri', '1.5.2'
# Provides String#to_ascii which is useful when screenscraping
gem 'stringex', '1.4.0'

gem 'active_hash', '0.9.10'

# For some reason this doesn't work if we require it right away
# gem 'colored', '1.2', :require => false

# gem 'map', '5.7.0'

#---

group :development do
  gem 'heroku', '~> 2.25.0'
  gem 'thin', '~> 1.3.1'
  # gem 'pry'
  # gem 'debugger'
  # gem 'awesome_print'
  # gem 'diffy'
end

#---

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'bourbon', '~> 2.1.0'

  gem 'uglifier', '>= 1.0.3'

  # execjs needs a Javascript runtime to function.
  # On Linux we can use therubyracer (v8); on Mac we don't have to do anything
  # since it already has JavascriptCore.
  # There isn't really a good way to do this otherwise.
  # See https://github.com/carlhuda/bundler/wiki/Platform-as-a-parameter
  gem 'therubyracer', '~> 0.9.8', :require => (RUBY_PLATFORM.include?('linux') && 'v8')
end
