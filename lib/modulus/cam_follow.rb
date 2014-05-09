module CamFollow

  def init_cam_follow factor, smoothing
    @cam_follow_factor = factor
    @cam_smoothing = smoothing
  end

  def do_cam_follow dt, t
    @engine.cam_x += ((@x + @cam_follow_factor*@vx)-@engine.cam_x)*@cam_smoothing
    @engine.cam_y += ((@y + @cam_follow_factor*@vy)-@engine.cam_y)*@cam_smoothing
  end

end