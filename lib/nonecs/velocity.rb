module Velocity

  def velocity
    @velocity
  end
  
  def do_velocity dt, t
    @position[:x] += @velocity[:x] * dt
    @position[:y] += @velocity[:y] * dt
  end
  
end