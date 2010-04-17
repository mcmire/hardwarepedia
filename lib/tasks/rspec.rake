begin
  require 'rspec/core'
  require 'rspec/core/rake_task'
rescue MissingSourceFile 
  module Rspec
    module Core
      class RakeTask
        def initialize(name)
          task name do
            # if rspec-rails is a configured gem, this will output helpful material and exit ...
            require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")

            # ... otherwise, do this:
            raise <<-MSG

#{"*" * 80}
*  You are trying to run an rspec rake task defined in
*  #{__FILE__},
*  but rspec can not be found in vendor/gems, vendor/plugins or system gems.
#{"*" * 80}
MSG
          end
        end
      end
    end
  end
end

Rake.application.instance_variable_get('@tasks').delete('default')

spec_prereq = File.exist?(File.join(Rails.root, 'config', 'database.yml')) ? "db:test:prepare" : :noop
task :noop do
end

task :default => :spec
task :stats => "spec:statsetup"

def create_spec_task(spec_level)
  task_name = (spec_level == :all ? :spec : "spec:#{spec_level}")
  dir = (spec_level == :all ? "spec/" : "spec/#{spec_level}")
  Rspec::Core::RakeTask.new(task_name) do |t|
    #t.spec_opts += ['--options', "spec/spec.opts"]
    #t.spec_opts += ['--example', ENV["EXAMPLE"]] if ENV["EXAMPLE"]
    #t.spec_opts += ['--line', ENV["LINE"]] if ENV["LINE"]
    if spec_level == :integration || spec_level == :all
      #t.spec_opts += ['--format', 'nested']
      #
      # Since any environment variables executed along with 'rake spec' are not
      # propagated to the specs themselves, store the options in a file which
      # we'll then read later when we run the specs.
      #
      # To run the javascript tests, simply pass JS=1 to 'rake spec'.
      #
      FileUtils.mkdir_p("tmp")
      options = {}
      options[:javascript] = (ENV["JS"] == "1")
      File.open("tmp/integration_spec.opts", "w") {|f| YAML.dump(options, f) }
    else
      #t.spec_opts += ['--format', 'specdoc']
    end
    t.pattern = "#{dir}/**/*_spec.rb"
  end
end

desc "Runs all specs"
create_spec_task(:all)

[:models, :mailers, :integration].each do |spec_level|
  desc "Runs specs in spec/#{spec_level}"
  create_spec_task(spec_level)
end

task "spec:statsetup" do
  require 'rails/code_statistics'
  ::STATS_DIRECTORIES << %w(Model\ specs spec/models) if File.exist?('spec/models')
  ::STATS_DIRECTORIES << %w(View\ specs spec/views) if File.exist?('spec/views')
  ::STATS_DIRECTORIES << %w(Controller\ specs spec/controllers) if File.exist?('spec/controllers')
  ::STATS_DIRECTORIES << %w(Helper\ specs spec/helpers) if File.exist?('spec/helpers')
  ::STATS_DIRECTORIES << %w(Library\ specs spec/lib) if File.exist?('spec/lib')
  ::STATS_DIRECTORIES << %w(Mailer\ specs spec/mailers) if File.exist?('spec/mailers')
  ::STATS_DIRECTORIES << %w(Routing\ specs spec/routing) if File.exist?('spec/routing')
  ::STATS_DIRECTORIES << %w(Request\ specs spec/requests) if File.exist?('spec/requests')
  ::CodeStatistics::TEST_TYPES << "Model specs" if File.exist?('spec/models')
  ::CodeStatistics::TEST_TYPES << "View specs" if File.exist?('spec/views')
  ::CodeStatistics::TEST_TYPES << "Controller specs" if File.exist?('spec/controllers')
  ::CodeStatistics::TEST_TYPES << "Helper specs" if File.exist?('spec/helpers')
  ::CodeStatistics::TEST_TYPES << "Library specs" if File.exist?('spec/lib')
  ::CodeStatistics::TEST_TYPES << "Mailer specs" if File.exist?('spec/mailer')
  ::CodeStatistics::TEST_TYPES << "Routing specs" if File.exist?('spec/routing')
  ::CodeStatistics::TEST_TYPES << "Request specs" if File.exist?('spec/requests')
end