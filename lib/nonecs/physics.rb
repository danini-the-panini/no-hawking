require_relaitve 'force'
require_relaitve 'acceleration'
require_relaitve 'velocity'

module Physics

  include Force
  include Acceleration
  include Velocity

  def do_physics dt, t
    do_force dt, t
    do_acceleration dt, t
    do_velocity dt, t
  end

end