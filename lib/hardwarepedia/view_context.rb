
module Hardwarepedia
  # Swiped from Draper
  module ViewContext
    THREAD_KEY = :current_view_context

    def self.current
      Thread.current[THREAD_KEY]
    end

    def self.current=(input)
      Thread.current[THREAD_KEY] = input
    end
  end
end
