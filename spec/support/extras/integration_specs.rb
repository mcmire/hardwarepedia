require 'capybara/rails'

Capybara.app_host = "http://localhost:3100"
Capybara.javascript_driver = :culerity
Capybara.run_server = false
Capybara.default_selector = :css
Capybara.debug = true

module Capybara
  class Server
    # Added: extracted from #is_port_open? so that the Celerity driver can access it
    def self.reachable?(host, port)
      Timeout::timeout(1) do
        begin
          s = TCPSocket.new(host, port)
          s.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          return false
        end
      end
    rescue Timeout::Error
      return false
    end
    
    # Patched: Extracted to .is_port_open?
    def is_port_open?(tested_port)
      self.class.reachable?(host, tested_port)
    end
  end
  
  module Driver
    class Celerity
      # Patched: Check that the app_host is reachable, if that specified
      def initialize(app)
        @app = app
        @rack_server = Capybara::Server.new(@app)
        if Capybara.run_server
          @rack_server.boot
        elsif Capybara.app_host
          host, port = Capybara.app_host.split("//")[1].split(":")
          msg = "It doesn't look like your app at #{Capybara.app_host} is reachable. Should you have started it beforehand?"
          Capybara::Server.reachable?(host, port) or raise(msg)
        else
          # we know by this point the rack server is up
          # so don't worry about checking that
        end
      end
    end
    
    class Culerity
      # Patched: Use firefox3 instead of firefox and make sure ajax is synchronized
      def browser
        unless @_browser
          @_browser = ::Culerity::RemoteBrowserProxy.new self.class.server, {:browser => :firefox3, :log_level => :fine, :javascript_exceptions => true, :resynchronize => true}
          at_exit do
            @_browser.exit if @_browser
          end
        end
        @_browser
      end
      
      def clear_browser
        @_browser.exit if @_browser
      end
    end
  end
end

#module Capybara
#  module Searchable
#    def all(*args)
#      options = if args.last.is_a?(Hash) then args.pop else {} end
#      if args[1].nil?
#        kind, locator = Capybara.default_selector, args.first
#      else
#        kind, locator = args
#      end
#      if kind == :css
#        options = {}
#        options[:prefix] = "./" unless self.class == Capybara::Session
#        locator = XPath.from_css(locator, options)
#      end
#
#      puts "Locator: #{locator}"
#
#      results = all_unfiltered(locator)
#
#      if options[:text]
#        results = results.select { |n| n.text.match(options[:text]) }
#      end
#
#      if options[:visible] or Capybara.ignore_hidden_elements
#        results = results.select { |n| n.visible? }
#      end
#
#      results
#    end
#  end
#  
#  class XPath
#    class << self
#      def from_css(css, options={})
#        Nokogiri::CSS.xpath_for(css, options).first
#      end
#      alias_method :for_css, :from_css
#    end
#  end
#end

#-------------------

# INTEGRATION SPEC CODE
#
# The code here is adapted from unencumbered [1] and steak [2].
# Coincidentally this is also like storyteller [3].
# Next up: creating something like stories? [4].
#
# [1]: http://github.com/hashrocket/unencumbered/blob/master/lib/unencumbered.rb
# [2]: http://github.com/cavalle/steak
# [3]: http://github.com/foca/storyteller
# [4]: http://github.com/citrusbyte/stories
#
# This has been upgraded to Rails 3
#
module Rspec::Core::KernelExtensions
  def feature(description, &block)
    # the caller here is essential or else the --line option to `spec` doesn't work
    # XXX: I don't think this works since Rspec overrides caller...
    describe("Feature: #{description}", :type => :integration, :caller => caller(0), &block)
  end
end

module IntegrationExampleGroupBehavior
  def self.included(includer)
    includer.extend(ClassMethods)
    includer.class_eval do
      include Capybara
      include Tableish
    end
    if defined?(Rails)
      includer.class_eval do
        include ActionDispatch::Integration::Runner
        include ActionController::RecordIdentifier
      end
    end
  end
  
  module InstanceMethods
    def current_path
      uri = URI.parse(current_url)
      path = uri.path
      path += "?" + uri.query if uri.query
      path
    end
  
    #def html
    #  page.driver.html
    #end
  
    def body_as_text
      page.driver.html.text
    end
  
    # Override wait_until so that instead of waiting for the specified amount of time
    # and then failing if the block fails, retries the block every 0.5 for the
    # specified amount of time. This made more sense to me.
    def wait_until(timeout=10, &block)
      time = Time.now
      success = false
      until success
        if (Time.now - time) >= timeout
          raise "Waited for #{timeout} seconds, but block never returned true"
        end
        sleep 0.5
        success = yield
      end
    end

    # Copied from Steak
    def method_missing(sym, *args, &block)
      return Rspec::Matchers::BePredicate.new(sym, *args, &block) if sym.to_s =~ /^be_/
      return Rspec::Matchers::Has.new(sym, *args, &block) if sym.to_s =~ /^have_/
      super
    end
  end

  module ClassMethods
    def self.extended(extender)
      extender.after do
        # Reset sessions so that things like session[:whatever] do not carry over into other tests
        Capybara.reset_sessions!
      end
    end
  
    def background(&block)
      before(:each, &block)
    end
  
    def scenario(description, options={}, &block)
      # the caller here is essential or else the --line option to `spec` doesn't work
      # XXX: I don't think this works since Rspec overrides caller...
      it("Scenario: #{description}", {:caller => caller(0)}.merge(options), &block)
    end
  
    def xscenario(description)
      # the caller here is essential or else the --line option to `spec` doesn't work
      # XXX: I don't think this works since Rspec overrides caller...
      scenario(description, :caller => caller(0))
    end

    # XXX: Might be easier just to do this manually, when saying 'feature'
    def story(story_content)
      story_content = story_content.strip.split(/[ \t]*\n+[ \t]*/).map {|line| "  #{line}\n" }.join    
      metadata[:example_group][:description] << "\n"+story_content+"\n"
      #metadata[:example_group][:full_description] << "\n"+story_content
    end
  
    def javascript(&block)
      run_javascript_tests = File.exists?("tmp/integration_spec.opts") && !!YAML.load_file("tmp/integration_spec.opts")[:javascript]
      return unless run_javascript_tests
      describe "(under Javascript)" do
        include JavascriptExampleMethods
        instance_eval(&block)
      end
    end
    
    def js(&block)
      javascript(&block)
    end
    
    module JavascriptExampleMethods
      def self.included(includer)
        # Copied from Capybara's Cucumber mixin
        includer.before(:all) do
          # TODO : Turn off transactions??
          Capybara.current_driver = Capybara.javascript_driver
          @_old_env = RAILS_ENV
          silence_warnings do
            env = "integration"
            env = Object.const_set(:RAILS_ENV, ENV["RAILS_ENV"] = env)
            ActiveRecord::Base.establish_connection(env)
          end
          @_use_transactional_fixtures = self.class.use_transactional_fixtures
          self.class.use_transactional_fixtures = false
        end
        
        # Basically what we're doing here is telling RSpec to truncate/seed the database
        # BEFORE any before(:each) blocks in the superclass are executed
        block = lambda do
          puts "Truncating the #{RAILS_ENV} database..."
          App.truncate_database(false)
          puts "Seeding the #{RAILS_ENV} database..."
          App.seed_database
        end
        includer.before_eachs.unshift(block)
        
        includer.after(:all) do
          #page.driver.clear_browser
          Capybara.use_default_driver
          env = @_old_env
          silence_warnings do
            env = Object.const_set(:RAILS_ENV, ENV["RAILS_ENV"] = env)
            ActiveRecord::Base.establish_connection(env)
          end
          self.class.use_transactional_fixtures = @_use_transactional_fixtures
        end
      end
      
      def browser
        page.driver.browser
      end
    
      def body_as_text
        browser.document.as_text
      end
    
      #def html
      #  @html ||= Nokogiri::HTML(body)
      #end
    
      # Override this to use Celerity's wait_until since Capybara doesn't seem to do this already
      def wait_until(timeout, &block)
        browser.wait_until(timeout, &block)
      end
    end
  end
  
  # Copied from cucumber-rails
  # http://github.com/aslakhellesoy/cucumber-rails/blob/master/lib/cucumber/web/tableish.rb
  module Tableish
    def tableish(row_selector, column_selectors)
      html = defined?(Capybara) ? body : response_body
      doc = Nokogiri::HTML(html)
      column_count = nil
      doc.search(row_selector).map do |row|
        cells = case(column_selectors)
        when String
          row.search(column_selectors)
        when Proc
          column_selectors.call(row)
        end
        column_count ||= cells.length
        (0...column_count).map do |n|
          cell = cells[n]
          case(cell)
            when String then cell.strip
            when nil then ''
            else cell.text.strip
          end
        end
      end
    end
  end
  
  Rspec.configure do |c|
    c.include self, :type => :integration
  end
end