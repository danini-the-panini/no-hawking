require_relative '../engine/component'

class FaceMouse < Garbage::Component
  def update
    mx = @engine.main_camera.camera.screen2world_x @engine.window.mouse_x
    my = @engine.main_camera.camera.screen2world_y @engine.window.mouse_y

    rad = Math::atan2(my-@entity.transform.position.y,
                      mx-@entity.transform.position.x)
    @entity.transform.rotation = (rad*180.0)/Math::PI
  end
end
