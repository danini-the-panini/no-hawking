require 'gosu'

module Garbage
  class Timepiece
    MILLISECOND = 0.001

    def initialize time=0.0
      @time = time
      @last_time = 0.0
      @delta = 0.0
    end

    def tick
      new_time = Gosu::milliseconds
      @delta = (new_time-@last_time).to_f*MILLISECOND
      @time += @delta
      @last_time = new_time
    end

    def time
      @time
    end

    def delta
      @delta
    end
  end
end
