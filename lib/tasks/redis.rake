
namespace :redis do
  NAME = 'redis-server'

  def running?
    out = `ps aux | grep #{NAME} | grep -v "grep #{NAME}"`
    out = out.squeeze(' ').strip
    not out.empty?
  end

  task :start do
    if running?
      puts "Redis is already running."
    else
      system('redis-server /usr/local/etc/redis.conf &>/dev/null &')
      puts "Redis started."
    end
  end

  task :stop do
    if running?
      system('killall redis-server')
      puts "Redis stopped."
    else
      puts "Redis isn't running."
    end
  end

  task :restart => [:stop, :start]
end
