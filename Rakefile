#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Hardwarepedia::Application.load_tasks

$RUNNING_RAKE_TASK = 1

task :noop do
  puts 'does nothing'
end
