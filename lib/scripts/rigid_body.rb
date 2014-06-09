require_relative '../engine/component'

class RigidBody < Garbage::Component
  def initialize radius
    @radius = radius
  end

  def update
    @engine.each_with_component :rigid_body do |other|
      if other.id > @entity.id
        mindist = radius+other.rigid_body.radius
        dx = other.transform.position.x - @entity.transform.position.x
        dy = other.transform.position.y - @entity.transform.position.y
        lsq = len_sq(dx,dy)
        if lsq <= sq(mindist)
          len = Math::sqrt(lsq)
          offset = (mindist - len)/2
          ndx = dx/len
          ndy = dy/len
          @entity.transform.translate(-ndx*offset, -ndy*offset)
          other.transform.translate(ndx*offset, ndy*offset)

          dot_dn = dot(2*@entity.physics.velocity.x,2*@entity.physics.velocity.y,ndx,ndy)
          @entity.physics.velocity.x -= dot_dn*ndx
          @entity.physics.velocity.y -= dot_dn*ndy

          dot_dn2 = dot(2*other.physics.velocity.x,2*other.physics.velocity.y,-ndx,-ndy)
          other.physics.velocity.x -= dot_dn2*-ndx
          other.physics.velocity.y -= dot_dn2*-ndy
        end
      end
    end
  end
end
