# RVM settings
#-------------------------------------------------------------------------------
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
set :rvm_type, :local
set :rvm_ruby_string, "jruby"

# SSH settings
#-------------------------------------------------------------------------------
server "localhost", :app, :web, :db, :primary => true

# SCM settings
#-------------------------------------------------------------------------------
set :scm, :none
set :repository, "."

# Deployment settings
#-------------------------------------------------------------------------------
set :deploy_to, "/tmp/capistrano-tests/#{application}"
set :deploy_via, :copy