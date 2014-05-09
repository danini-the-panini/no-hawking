module CamFollow

  def do_cam_follow dt, t
    @engine.camera[:x] += ((@position[:x] + @cam_follow_factor*@velocity[:x])-@engine.camera[:x])*@camera_smoothing
    @engine.camera[:y] += ((@position[:y] + @cam_follow_factor*@velocity[:y])-@engine.camera[:y])*@camera_smoothing
  end

end