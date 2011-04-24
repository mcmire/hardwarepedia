# SSH settings
#-------------------------------------------------------------------------------
set :user, "www"
# -- No need for password since we will be logging in using an SSH key
set :group, "staff"
server "173.255.244.140", :app, :web, :db, :primary => true

# Deployment settings
#-------------------------------------------------------------------------------
set :deploy_to, "/var/www/#{application}"
# In order to speed up subsequent deployments, keep a local copy of the repo in a temp location
# so that Cap can merely run a fetch on this instead of pulling down the whole repo again
set :deploy_via, :remote_cache

set :rails_env, "production"