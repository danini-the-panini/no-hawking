module FollowMouse

  def init_follow_mouse
  end

  def do_follow_mouse dt, t
    mx, my = @engine.mouse_in_world_coords
    rad = Math::atan2(my-@y, mx-@x)
    @rotation = (rad*180.0)/Math::PI
  end

end