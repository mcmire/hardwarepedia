require 'colored'

module Hardwarepedia
  class Logger
    include Singleton

    def info(msg)
      $stdout.puts msg.to_s.yellow
    end
    
    def error(msg)
      $stderr.puts msg.to_s.red
    end
  end
end