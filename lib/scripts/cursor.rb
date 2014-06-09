require_relative '../engine/component'

class Cursor < Garbage::Component
  def update
    mx = @engine.main_camera.camera.screen2world_x @engine.window.mouse_x
    my = @engine.main_camera.camera.screen2world_y @engine.window.mouse_y
    @entity.transform.position = Vector[mx,my]
  end
end
