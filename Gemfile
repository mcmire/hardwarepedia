source :rubygems

# This isn't strictly necessary, but we want to make sure the server has the
# right version of Bundler
gem 'bundler', '1.0.12'

# Require these explicitly since we want to exclude ActiveRecord
%w(actionmailer actionpack activesupport railties).each do |name|
  gem name, '3.0.7'
end

# Needed as a part of a standard JRuby install
platforms :jruby do
  gem 'jruby-openssl', '0.7.3'
end

#---

# Awesome MongoDB ORM
# Site: http://mongomapper.com
# Code: http://github.com/jnunemaker/mongomapper
gem 'mongo_mapper', '0.9.0'

#gem 'mongo_session_store', :git => 'git://github.com/nicolaracco/mongo_session_store.git'

# Haml (Pythonic HTML) and Sass (Awesome improvements to CSS)
# (We don't use Haml)
# Site: http://sass-lang.com/
# Code: http://github.com/nex3/haml
gem 'haml', '3.0.25'

# Provides Sass helpers for easily using CSS3 features cross-browser
# Code: http://github.com/chriseppstein/compass
# Project home: http://compass-style.org
gem 'compass', '0.10.6'

# DRY up your views
# Code: http://github.com/fredwu/inherited_resources_views
#gem 'inherited_resources_views', '0.4.1'

# Cleaner way of writing forms, and handles associations, too
# Code: http://github.com/plataformatec/simple_form
gem 'simple_form', '1.2.2'

# Rack-based authentication solution based on Warden
# Code: http://github.com/plataformatec/devise
#gem 'devise', '1.1.3'

# Provides controller and view methods to make displaying of window/page titles DRYer
# Code: http://github.com/mcmire/hierarchical_page_titles
gem 'hierarchical_page_titles', '0.1.1'

# Provides a dirt-simple way to specify items that will go in your navbar
# Code: http://github.com/andi/simple-navigation
gem 'simple-navigation', '3.1.0'

# An XML parser written in C
# Site: http://nokogiri.org
# Code: http://github.com/tenderlove/nokogiri
#platforms :jruby do
  # Make sure you have libxml-dev and libxslt-dev installed before you install this
  gem 'nokogiri', '~> 1.4.4'
#end

# JSON encoding/encoding
# Code: http://github.com/flori/json
gem 'json', '1.5.1'

# Provides Rake tasks for preparing your test database, and better seeding
# Code: http://github.com/mcmire/kaplan
# (We include this in everywhere to expose Rake tasks without having to type RAILS_ENV=development)
gem 'kaplan', '0.2.4'
#gem 'kaplan', :path => "~/code/github/mine/kaplan"

# Use a hash like an ActiveRecord object (complete with finders, etc.).
# Perfect for `roles` and other data structures which store static data.
# Code: https://github.com/zilkey/active_hash
gem 'active_hash', '0.9.1'

# Adds color to Strings
# Code: http://github.com/defunkt/colored
# -- For some reason it doesn't work if we require it right away
gem 'colored', '1.2', :require => false

# Provides String#to_ascii which is useful when screenscraping
gem 'stringex', '1.2.1'

platforms :jruby do
  gem 'trinidad', '~> 1.1.1'
  gem 'trinidad_daemon_extension'
end

group :development do
  # (We include this in development to expose Rake tasks without having to type RAILS_ENV=test)
  #gem 'rspec-rails', '~> 2.2.0'

  # Reads your source files, generates documentation so you can look at it in a web browser
  # Project home: http://yardoc.org/
  # Code: http://github.com/lsegal/yard
  #gem 'yard', '~> 0.6.3'

  # Documentation is parsed as Markdown.
  #gem 'kramdown', '~> 0.12.0'

  # Adds RSpec examples to YARD documentation
  # Code: https://github.com/lsegal/yard-spec-plugin
  #gem 'yard-rspec', '~> 0.1.0'
  
  # I think we are only using this for require-profiler...
  #gem "term-ansicolor", :require => "term/ansicolor"
  
  gem 'capistrano', '~> 2.5.21'
  # Needed for the multistage stuff
  gem 'capistrano-ext', '~> 1.2.1'
  platforms :jruby do
    # Speeds up the highline gem (which Capistrano uses) in JRuby
    gem 'ffi-ncurses', '~> 0.3.3'
  end
end

group :test, :integration do
  # The quintessential testing library
  # Code: https://github.com/rspec/rspec
  # Project home: https://rspec.info
  gem 'rspec', '~> 2.2.0', :require => false
  # (We include this in development to expose Rake tasks without having to type RAILS_ENV=test)
  gem 'rspec-rails', '~> 2.2.0', :require => false

  # Speeds up development of tests by preloading Rails in another process
  # Code: http://github.com/timcharper/spork
  gem 'spork', '~> 0.9.0.rc4'

  # Factories, not fixtures
  # Code: http://github.com/thoughtbot/factory_girl
  # Article: http://robots.thoughtbot.com/post/159807023/waiting-for-a-factory-girl
  gem 'factory_girl', '~> 2.0.0.beta1', :require => false
  gem 'factory_girl_rails', :git => "git://github.com/thoughtbot/factory_girl_rails.git", :require => false

  # Mocking/stubbing library with support for spies and proxies
  # Code: http://github.com/btakita/rr
  gem 'rr', '~> 1.0.2', :require => false

  # Mock time in tests
  # Code: http://github.com/jtrupiano/timecop
  gem 'timecop', '~> 0.3.5'

  # Database-agnostic way of cleaning your database
  # Code: http://github.com/bmabey/database_cleaner
  gem 'database_cleaner', '~> 0.6.0'
  
  # Keeps your model specs DRYer by providing matchers for model macros like
  # belongs_to, has_many, validates_presence_of, etc.
  # Code: http://github.com/thoughtbot/shoulda
  # Documentation: http://rdoc.info/github/thoughtbot/shoulda/master/file/README.rdoc
  # (Defer loading until RSpec is loaded)
  gem 'shoulda-matchers', :require => false

  # Run your tests against a browser simulator
  # Code: http://github.com/jnicklas/capybara
  # Documentation: http://rdoc.info/github/jnicklas/capybara/master/file/README.rdoc
  gem 'capybara', '~> 0.4.1.rc'
  
  # Send pages being tested to your browser for viewing
   # Code: http://github.com/copiousfreetime/launchy
   gem 'launchy', '~> 0.3.7'
  
  # Allows you to use randomly generated names, email addresses, and words in factories
  # Code: https://github.com/stympy/faker
  # Docs: http://faker.rubyforge.org/rdoc/
  gem 'faker', '~> 0.9.5'
end