module Collision

  def collidable
    @collidable
  end

  def do_collision dt, t
    @engine.each_entity_after_me do |e2|
      mindist = @collidable[:radius]+e2.collidable[:radius]
      dx = e2.position[:x] - @position[:x]
      dy = e2.position[:y] - @position[:y]
      lsq = len_sq(dx,dy)
      if lsq <= sq(mindist)
        len = Math::sqrt(lsq)
        offset = (mindist - len)/2
        ndx = dx/len
        ndy = dy/len
        @position[:x] -= ndx*offset
        @position[:y] -= ndy*offset
        e2.position[:x] += ndx*offset
        e2.position[:y] += ndy*offset

        dot_dn = dot(2*@velocity[:x],2*@velocity[:y],ndx,ndy)
        @velocity[:x] -= dot_dn*ndx
        @velocity[:y] -= dot_dn*ndy

        dot_dn2 = dot(2*e2.velocity[:x],2*e2.velocity[:y],-ndx,-ndy)
        e2.velocity[:x] -= dot_dn2*-ndx
        e2.velocity[:y] -= dot_dn2*-ndy
      end
    end
  end

end