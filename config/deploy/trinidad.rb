# Override deploy:start/stop/restart to work with Trinidad
namespace :deploy do
  desc "Tells Trinidad to refresh on next request"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "Doesn't do anything"
    task t, :roles => :app do ; end
  end
end