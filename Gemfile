
source :rubygems

# This isn't strictly necessary, but we want to make sure the server has the
# right version of Bundler
gem 'bundler', '~> 1.1.0'

# gem 'rails', '3.2.3'
gem 'tzinfo'  # activesupport should be requiring this but it doesn't :(
gem 'activesupport', '3.2.3'
gem 'actionpack', '3.2.3'

gem 'ohm', '1.0.2'
# gem 'ohm', :path => '~/code/github/forks/ohm'
# gem 'ohm', :git => 'http://github.com/mcmire/ohm.git', :branch => 'mcmire'
gem 'ohm-contrib', '1.0.1', :require => 'ohm/contrib'

#---

gem 'mustache', '0.99.4'
gem 'stache', '0.9.1'
gem 'hierarchical_page_titles', '0.2.0'
gem 'simple-navigation', '3.7.0'
# Make sure you have libxml-dev and libxslt-dev installed before you install this
gem 'nokogiri', '1.5.2'
gem 'yajl-ruby', '1.1.0'
gem 'active_hash', '0.9.10'
# For some reason this doesn't work if we require it right away
gem 'colored', '1.2', :require => false
# Provides String#to_ascii which is useful when screenscraping
gem 'stringex', '1.4.0'
gem 'map', '5.7.0'
gem 'logging', '1.7.2'
gem 'logging-rails', '0.4.0'

#---

group :development do
  gem 'heroku', '~> 2.25.0'
  gem 'thin', '~> 1.3.1'
  gem 'pry'
  gem 'debugger'
  gem 'awesome_print'
  gem 'diffy'
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
