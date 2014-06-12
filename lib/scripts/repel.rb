require_relative '../engine/component'
require_relative '../engine/matrix_hacks'

class Repel < Garbage::Component
  def initialize repellant, factor = 1.0, range = Float::INFINITY
    @repellant = repellant
    @factor = factor
    @range = range
  end

  def update
    d = @repellant.transform.position - @entity.transform.position

    lsq = d.len_sq
    if lsq < sq(@range)
      len = Math::sqrt(lsq)
      ratio = 1.0-len/@range
      @entity.physics.driving_force =  (d/len)*-@factor*ratio
    else
      @entity.physics.driving_force = Garbage::VEC2_ZERO
    end
  end
end
