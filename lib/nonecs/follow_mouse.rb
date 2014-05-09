module FollowMouse

  def do_follow_mouse dt, t
    mx, my = @entity.mouse_in_world_coords
    rad = Math::atan2(my-@position[:y], mx-@position[:x])
    @rotation = (rad*180.0)/Math::PI
  end

end