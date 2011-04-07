source 'http://rubygems.org'

gem 'thin'

#gem 'rails', '3.0.0.beta3'
# Require these explicitly since we want to exclude ActiveRecord
%w(actionmailer actionpack activesupport railties).each do |name|
  gem name, '3.0.0.beta3'
end
gem 'bundler', ">= 0.9.19"

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Not sure why we need this?
#gem 'sqlite3-ruby', :require => 'sqlite3'

gem "mongoid", :git => "git://github.com/durran/mongoid.git"
gem "bson_ext", "0.20.1"

#gem 'mongo_session_store', :git => 'git://github.com/nicolaracco/mongo_session_store.git'

gem "inherited_resources", ">= 1.1.1"

gem "haml", "3.0.0.beta.3"

#gem "jammit", :git => "git://github.com/railsjedi/jammit.git"

gem "rails3-generators"

gem "term-ansicolor", :require => "term/ansicolor"

group :test do
  #gem "spork"
  gem "mcmire-mocha"
  gem "factory_girl", :git => "git://github.com/thoughtbot/factory_girl.git", :branch => "rails3"
  #gem "rspec-rails", ">= 2.0.0.beta.7"
  gem "rspec", ">= 2.0.0.beta.7"
  gem "capybara", ">= 0.3.7"
  gem "launchy"
end