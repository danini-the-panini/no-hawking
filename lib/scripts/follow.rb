require_relative '../engine/component'

class Follow < Garbage::Component
  def initialize to_follow, factor = 1.0, smoothing = 0.1
    @to_follow = to_follow
    @factor = factor
    @smoothing = smoothing
  end

  def update
    cam_movement =
      ((@to_follow.transform.position + @factor * @to_follow.physics.velocity) -
      @entity.transform.position) * @smoothing

    @entity.transform.position += cam_movement
  end
end
