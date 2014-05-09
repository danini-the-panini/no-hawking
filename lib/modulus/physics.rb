require_relative 'force'
require_relative 'acceleration'
require_relative 'velocity'

module Physics

  include Force
  include Acceleration
  include Velocity

  def init_physics vx = 0.0, vy = 0.0, ax = 0.0, ay = 0.0, fx = 0.0, fy = 0.0, m = 1.0
    init_force fx, fy, m
    init_acceleration ax, ay
    init_velocity vx, vy
  end

  def do_physics dt, t
    do_force dt, t
    do_acceleration dt, t
    do_velocity dt, t
  end

end