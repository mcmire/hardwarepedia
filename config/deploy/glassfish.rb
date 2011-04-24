# The problem with this script is that cd'ing to the current path doesn't help...
# the script itself needs to do this
# Also the options in the file and the options on the command line are not being mixed appropriately
# because we are getting "pid option only applies when daemon" error
# Actually, the glassfish-gem just needs to provide its own daemon.........

namespace :deploy do
  desc "Start Glassfish Gem from a shutdown state"
  task :cold do
    start
  end

  desc "Stop a server running GlassFish gem"
  task :stop do
    run "cd #{current_path} && /etc/init.d/gfish-#{application} stop"
  end

  desc "Starts a server running GlassFish gem"
  task :start do
    run "cd #{current_path} && /etc/init.d/gfish-#{application} start"
  end

  desc "Restarts a server running GlassFish gem"
  task :restart do
    run "cd #{current_path} && /etc/init.d/gfish-#{application} restart"
  end
end