module CamFollow

  def init_cam_follow factor, smoothing
    @cam_follow_factor = factor
    @cam_smoothing = smoothing
  end

  def do_cam_follow dt, t
    @engine.camera[:x] += ((@x + @cam_follow_factor*@vx)-@engine.camera[:x])*@cam_smoothing
    @engine.camera[:y] += ((@y + @cam_follow_factor*@vy)-@engine.camera[:y])*@cam_smoothing
  end

end