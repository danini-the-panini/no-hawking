module Collision

  def init_collidable radius
    @radius = radius
  end

  def radius
    @radius
  end

  def do_collision dt, t
    @engine.each_entity_after_me do |e2|
      mindist = @radius+e2.radius
      dx = e2.x - @x
      dy = e2.y - @y
      lsq = len_sq(dx,dy)
      if lsq <= sq(mindist)
        len = Math::sqrt(lsq)
        offset = (mindist - len)/2
        ndx = dx/len
        ndy = dy/len
        @x -= ndx*offset
        @y -= ndy*offset
        e2.x += ndx*offset
        e2.y += ndy*offset

        dot_dn = dot(2*@vx,2*@vy,ndx,ndy)
        @vx -= dot_dn*ndx
        @vy -= dot_dn*ndy

        dot_dn2 = dot(2*e2.vx,2*e2.vy,-ndx,-ndy)
        e2.vx -= dot_dn2*-ndx
        e2.vy -= dot_dn2*-ndy
      end
    end
  end

end