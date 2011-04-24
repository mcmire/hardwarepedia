namespace :deploy do
  desc "Start Glassfish Gem from a shutdown state"
  task :cold do
    start
  end

  desc "Stop a server running GlassFish gem"
  task :stop do
    run "/etc/init.d/gfish-#{application} stop"
  end

  desc "Starts a server running GlassFish gem"
  task :start do
    run "/etc/init.d/gfish-#{application} start"
  end

  desc "Restarts a server running GlassFish gem"
  task :restart do
    run "/etc/init.d/gfish-#{application} restart"
  end
end