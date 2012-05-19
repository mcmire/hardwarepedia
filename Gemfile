
source :rubygems

# This isn't strictly necessary, but we want to make sure the server has the
# right version of Bundler
gem 'bundler', '~> 1.1.0'

gem 'rails', '3.2.3'

gem 'pg', '0.13.2'

#---

gem 'hierarchical_page_titles', '0.2.0'
gem 'simple-navigation', '3.7.0'
# Make sure you have libxml-dev and libxslt-dev installed before you install this
gem 'nokogiri', '1.5.2'
gem 'yajl-ruby', '1.1.0'
gem 'active_hash', '0.9.10'
# For some reason it doesn't work if we require this right away
gem 'colored', '1.2', :require => false
# Provides String#to_ascii which is useful when screenscraping
gem 'stringex', '1.4.0'

#---

group :development do
  gem 'heroku', '~> 2.25.0'
  gem 'thin', '~> 1.3.1'
end

#---

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'bourbon', '~> 2.1.0'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platform => :ruby

  gem 'uglifier', '>= 1.0.3'

  # execjs needs a Javascript runtime to function.
  # On Linux we can use therubyracer (v8); on Mac we don't have to do anything
  # since it already has JavascriptCore.
  # There isn't really a good way to do this otherwise.
  # See https://github.com/carlhuda/bundler/wiki/Platform-as-a-parameter
  gem 'therubyracer', '~> 0.9.8', :require => (RUBY_PLATFORM.include?('linux') && 'v8')
end
