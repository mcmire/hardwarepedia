require 'pp'
module Kernel
  class LoggerAppender
    include Singleton
    def <<(msg)
      Rails.logger << "\e[33m"
      Rails.logger << (msg || "")
      Rails.logger << "\e[0m"
      msg
    end
  end
  
  # pretty print to Rails log
  def ppl(*objs)
    objs.each {|obj|
      PP.pp(obj, LoggerAppender.instance)
    }
    nil
  end
  module_function :ppl
end