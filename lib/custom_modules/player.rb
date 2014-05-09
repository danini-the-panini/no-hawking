require_relative '../modulus/engine'

module Player
  include CamFollow
  include Control
  include FollowMouse
  include Friction
  include Physics
  include Position

  def init_player x = 0.0, y = 0.0
    init_cam_follow 1.0, 0.1
    init_control 200
    init_follow_mouse
    init_friction 0.8
    init_physics
    init_position x, y
  end

  def do_player dt, t
    do_follow_mouse dt, t
    do_control dt, t
    do_friction dt, t
    do_physics dt, t
  end
end