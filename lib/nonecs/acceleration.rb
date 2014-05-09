module Acceleration
  
  def acceleration
    @acceleration
  end

  def do_acceleration dt, t
    @velocity[:x] += @acceleration[:x] * dt
    @velocity[:y] += @acceleration[:y] * dt
  end
  
end