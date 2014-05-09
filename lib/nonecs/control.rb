require 'gosu'

module Control

  def do_control dt, t
    if @engine.down? Gosu::KbA
      @force[:x] -= @player[:a]
    end
    if @engine.down? Gosu::KbD
      @force[:x] += @player[:a]
    end
    if @engine.down? Gosu::KbW
      @force[:y] -= @player[:a]
    end
    if @engine.down? Gosu::KbS
      @force[:y] += @player[:a]
    end
  end

end