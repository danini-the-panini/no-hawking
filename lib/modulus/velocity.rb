module Velocity

  def init_velocity x = 0.0, y = 0.0
    @vx = x
    @vy = y
  end

  def vx
    @vx
  end

  def vy
    @vy
  end
  
  def do_velocity dt, t
    @x += @vx * dt
    @y += @vy * dt
  end
  
end