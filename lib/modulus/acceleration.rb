module Acceleration
  
  def init_acceleration x = 0.0, y = 0.0
    @ax = x
    @ay = y
  end

  def ax
    @ax
  end

  def ay
    @ay
  end

  def do_acceleration dt, t
    @vx += @ax * dt
    @vy += @ay * dt
  end
  
end