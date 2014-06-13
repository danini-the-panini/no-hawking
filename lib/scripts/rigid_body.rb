require_relative '../engine/component'

class RigidBody < Garbage::Component
  def initialize radius, source = nil, ignore_list = []
    @radius = radius
    @source = source
    @ignore_list = ignore_list
  end

  def radius
    @radius
  end

  def update
    @engine.each_with_component :rigid_body do |other|
      if other.id > @entity.id || @source == other ||
          @ignore_list.include?(other.tag)
        mindist = @radius+other.rigid_body.radius
        d = other.transform.position - @entity.transform.position
        md = @entity.transform.position - other.transform.position
        lsq = d.len_sq
        if lsq <= sq(mindist)
          # TODO: This doesn't behave 100%
          # TODO: add more physics geometries
          len = Math::sqrt(lsq)
          mtd = md * (mindist-len)/len
          n = mtd.zero? ? Garbage::VEC2_ZERO : mtd.normalize

          im1 = 1.0 / @entity.physics.mass
          im2 = 1.0 / other.physics.mass

          # push-pull them apart based off their mass
          @entity.transform.position += mtd * (im1 / (im1 + im2))
          other.transform.position -= mtd * (im2 / (im1 + im2))

          collision_point =
            ((@entity.transform.position * other.rigid_body.radius) +
               (other.transform.position * @radius)) /
            (@radius + other.rigid_body.radius)

          v = (@entity.physics.velocity - (other.physics.velocity))
          vn = v.dot n

          # sphere intersecting but moving away from each other already
          next if vn > 0.0

          # collision impulse
          i = (-(1.0 + 0.5) * vn) / (im2 + im2)
          impulse = n * i

          # change in momentum
          @entity.physics.velocity = @entity.physics.velocity + impulse * im1
          other.physics.velocity = other.physics.velocity - impulse * im2

          other.on_hit(@entity)
          on_hit(other)
        end
      end
    end
  end

end
