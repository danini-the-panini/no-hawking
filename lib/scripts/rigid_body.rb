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
      if other.id > @entity.id || @source == other || @ignore_list.include?(other.tag)
        mindist = @radius+other.rigid_body.radius
        dx = other.transform.position.x - @entity.transform.position.x
        dy = other.transform.position.y - @entity.transform.position.y
        lsq = len_sq(dx,dy)
        if lsq <= sq(mindist)
          # TODO: This doesn't behave 100%
          len = Math::sqrt(lsq)
          offset = (mindist - len)/2
          ndx = dx/len
          ndy = dy/len
          @entity.transform.translate(-ndx*offset, -ndy*offset)
          other.transform.translate(ndx*offset, ndy*offset)

          dot_dn = dot(2*@entity.physics.velocity.x,
                       2*@entity.physics.velocity.y,
                       ndx,ndy)
          @entity.physics.velocity -= Vector[dot_dn*ndx,dot_dn*ndy]

          dot_dn2 = dot(2*other.physics.velocity.x,
                        2*other.physics.velocity.y,
                        -ndx,-ndy)
          other.physics.velocity -= Vector[dot_dn2*-ndx,dot_dn2*-ndy]

          other.on_hit(@entity)
          on_hit(other)
        end
      end
    end
  end

  private

    def len_sq x, y
      x*x + y*y
    end

    def dot x1, y1, x2, y2
      x1*x2 + y1*y2
    end

    def sq x
      x*x
    end
end
