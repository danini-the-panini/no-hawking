require 'gosu'

module Control

  def init_control thrust
    @thrust = thrust
  end

  def do_control dt, t
    if @engine.down? Gosu::KbA
      @fx -= @thrust
    end
    if @engine.down? Gosu::KbD
      @fx += @thrust
    end
    if @engine.down? Gosu::KbW
      @fy -= @thrust
    end
    if @engine.down? Gosu::KbS
      @fy += @thrust
    end
  end

end