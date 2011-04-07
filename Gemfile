source :rubygems

gem "thin", '1.2.11'

# Require these explicitly since we want to exclude ActiveRecord
%w(actionmailer actionpack activesupport railties).each do |name|
  gem name, '3.0.5'
end
gem "bundler", '1.0.10'

gem "mongoid", '2.0.1'
gem "bson_ext", '1.3.0'

#gem 'mongo_session_store', :git => 'git://github.com/nicolaracco/mongo_session_store.git'

gem "haml", '3.0.25'

gem "hierarchical_page_titles", '0.1.1'
gem "kaplan", '0.2.4'

group :development do
  gem "term-ansicolor", :require => "term/ansicolor"
end

=begin
group :test do
  gem "spork"
  gem "rspec"
  gem "rr"
  gem "factory_girl", :git => "git://github.com/thoughtbot/factory_girl.git", :branch => "rails3"
  #gem "rspec-rails", ">= 2.0.0.beta.7"
  gem "rspec", ">= 2.0.0.beta.7"
  gem "capybara", ">= 0.3.7"
  gem "launchy"
end
=end