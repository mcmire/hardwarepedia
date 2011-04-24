# Bundler
#-------------------------------------------------------------------------------
# Run bundle install on deploy
require "bundler/capistrano"
# Runtime dependencies (checked on `cap deploy:check`)
depend :remote, :gem, "bundler", ">= 1.0.0"

# Enable multi-stage support
#-------------------------------------------------------------------------------
set :stage_dir, "config/deploy/stages"
set :stages, %w(production local)
set :default_stage, "production"
require "capistrano/ext/multistage"

# Global options
#-------------------------------------------------------------------------------
set :application, "hardwarepedia"
# No need for sudo since we have our own user on the production server,
# and we're logging in as ourselves locally
set :use_sudo, false
# When Capistrano ssh'es into the server, use my local key instead of the key
# installed on the server
ssh_options[:forward_agent] = true
# Options necessary to make Ubuntu’s SSH happy
ssh_options[:paranoid]    = false
default_run_options[:pty] = true

# SCM settings
#-------------------------------------------------------------------------------
set :scm, :git
set :repository, "http://github.com/mcmire/hardwarepedia"
# Tell git to clone only the latest revision and not the whole repository
set :git_shallow_clone, 1
# When Cap checks out the code, also initialize and update the submodules
set :git_enable_submodules, 1

load File.expand_path("../deploy/glassfish.rb", __FILE__)