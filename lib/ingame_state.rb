require_relative 'engine_state'

class IngameState < EngineState
  def initialize window
    super

    @camera = {:x => 0, :y => 0}
    @cam_follow_factor = 1.0
    @cam_buffer = 20
    @sleep_radius = 1000

    @particle = Gosu::Image.new @window, "effects/spr_particle.png"

    @spr_bar_bg = Gosu::Image.new @window, "ui/spr_bar_bg.png"
    @spr_bar_hawking = Gosu::Image.new @window, "ui/spr_bar_hawking.png"

    @spr_probe = Gosu::Image.new @window, "actors/spr_probe.png"

    @visited_chunks = {}
    @chunk_size = 1000

    @engine
    .add_system(:update, :control, :player) do |e, dt, t|
      e[:driving_force] = zero
      if @engine.down? Gosu::KbA
        e[:driving_force][:x] -= e[:player][:a]
      end
      if @engine.down? Gosu::KbD
        e[:driving_force][:x] += e[:player][:a]
      end
      if @engine.down? Gosu::KbW
        e[:driving_force][:y] -= e[:player][:a]
      end
      if @engine.down? Gosu::KbS
        e[:driving_force][:y] += e[:player][:a]
      end
    end
    .add_system(:update, :collision, :collidable) do |e, dt, t|
      @engine.each_entity(:collidable) do |e2|
        if e2[:id] > e[:id]
          mindist = e[:collidable][:radius]+e2[:collidable][:radius]
          dx = e2[:position][:x] - e[:position][:x]
          dy = e2[:position][:y] - e[:position][:y]
          lsq = len_sq(dx,dy)
          if lsq <= sq(mindist)
            len = Math::sqrt(lsq)
            offset = (mindist - len)/2
            ndx = dx/len
            ndy = dy/len
            e[:position][:x] -= ndx*offset
            e[:position][:y] -= ndy*offset
            e2[:position][:x] += ndx*offset
            e2[:position][:y] += ndy*offset

            dot_dn = dot(2*e[:velocity][:x],2*e[:velocity][:y],ndx,ndy)
            e[:velocity][:x] -= dot_dn*ndx
            e[:velocity][:y] -= dot_dn*ndy

            dot_dn2 = dot(2*e2[:velocity][:x],2*e2[:velocity][:y],-ndx,-ndy)
            e2[:velocity][:x] -= dot_dn2*-ndx
            e2[:velocity][:y] -= dot_dn2*-ndy
          end
        end
      end
    end
    .add_system(:update, :friction, :friction) do |e, dt, t|
      e[:friction][:x] = -e[:friction][:c]*e[:velocity][:x]
      e[:friction][:y] = -e[:friction][:c]*e[:velocity][:y]
    end
    .add_system(:update, :force, :force) do |e, dt, t|
      force = total_force(e)
      e[:acceleration][:x] = force[:x]/e[:mass]
      e[:acceleration][:y] = force[:y]/e[:mass]
    end
    .add_system(:update, :acceleration, :acceleration) do |e, dt, t|
      e[:velocity][:x] += e[:acceleration][:x]*dt
      e[:velocity][:y] += e[:acceleration][:y]*dt
    end
    .add_system(:update, :movement, :velocity) do |e, dt, t|
      e[:position][:x] += e[:velocity][:x]*dt
      e[:position][:y] += e[:velocity][:y]*dt

      xi = e[:position][:x].to_i / @chunk_size
      yi = e[:position][:y].to_i / @chunk_size

      if e[:chunk] != :default && (e[:chunk][0] != xi || e[:chunk][1] != yi)
        @engine.move_entity(e, [xi,yi])
      end
    end
    .add_system(:update, :cam_follow, :cam_follow) do |e, dt, t|
      @camera[:x] += ((e[:position][:x] + e[:cam_follow][:factor]*e[:velocity][:x])-@camera[:x])*e[:cam_follow][:smoothing]
      @camera[:y] += ((e[:position][:y] + e[:cam_follow][:factor]*e[:velocity][:y])-@camera[:y])*e[:cam_follow][:smoothing]
    end
    .add_system(:update, :emitter, :emitter) do |e, dt, t|
      if t-e[:emitter][:last_emit] > e[:emitter][:period]
        theta = Gosu::random(0,360)

        @engine.add_entity({
          :position => e[:position].dup,
          :velocity => {:x => e[:emitter][:velocity]*Math::cos(theta),
            :y => e[:emitter][:velocity]*Math::sin(theta)},
          :life => e[:emitter][:lifetime],
          :lifetime => e[:emitter][:lifetime],
          :sprite => e[:emitter][:sprite],
          :draw_mode => :additive
        }, :life, :velocity, :drawable)
      end
    end
    .add_system(:update, :life, :life) do |e, dt, t|
      e[:life] -= dt
      if e[:life] > 0
        e[:colour] = (((e[:life]/e[:lifetime])*0xFF).to_i << 24) | (e[:colour] ? (e[:colour] & 0x00FFFFFF) : 0x00FFFFFF)
      else
        @engine.remove_entity e, :all
      end
    end
    .add_system(:update, :follow_mouse, :follow_mouse) do |e, dt, t|
      mx, my = screen2world(@window.mouse_x, @window.mouse_y)
      rad = Math::atan2(my-e[:position][:y], mx-e[:position][:x])
      e[:rotation][:theta] = (rad*180.0)/Math::PI
    end
    .add_system(:update, :cursor, :cursor) do |e, dt, t|
      e[:position][:x] = @window.mouse_x
      e[:position][:y] = @window.mouse_y
    end
    .add_system(:update, :proc_gen, :player) do |e, dt, t|
      x1,y1 = screen2world(-@cam_buffer,-@cam_buffer)
      x2,y2 = screen2world(@window.width+@cam_buffer,@window.height+@cam_buffer)

      x1 = x1.to_i / @chunk_size
      y1 = y1.to_i / @chunk_size
      x2 = x2.to_i / @chunk_size
      y2 = y2.to_i / @chunk_size

      @visited_chunks.each do |k,v|
        @engine.deactivate_chunk(k)
      end

      (x1..x2).each do |xi|
        (y1..y2).each do |yi|
          if @visited_chunks[[xi,yi]].nil?
            @engine.add_chunk([xi,yi])
            proc_gen(xi, yi, @chunk_size)
            @visited_chunks[[xi,yi]] = true
          else
            @engine.activate_chunk([xi,yi])
          end
        end
      end
    end
    .add_system(:draw, :sprite_draw, :drawable) do |e|
      draw_entity e
    end
    .add_system(:draw, :hud_draw, :hud) do |e|
      draw_entity_nocam e
    end
    .add_entity({
      :cursor => true,
      :sprite => make_sprite(Gosu::Image.new @window, "ui/cursor.png"),
      :position => {:x => 0, :y => 0},
    }, :cursor, :hud)
  end

  def proc_gen xi, yi, chunk_size
  end

  def draw_entity e
    @window::translate(*world2screen(0,0)) do
      draw_entity_nocam e, 0
    end
  end

  def draw_entity_nocam e, z=1
    x = e[:position][:x]
    y = e[:position][:y]
    img = e[:sprite][:image]
    dx = e[:sprite][:anchor][:x]
    dy = e[:sprite][:anchor][:y]
    if e[:scale]
      sx = e[:scale][:x]
      sy = e[:scale][:y]
    else
      sx = 1
      sy = 1
    end
    theta = e[:rotation] ? e[:rotation][:theta] : 0
    colour = e[:colour] || 0xFFFFFFFF
    mode = e[:draw_mode] || :default
    img.draw_rot x, y, z, theta, dx, dy, sx, sy, colour, mode
  end

  def screen2world x, y
    [x-@window.width/2+@camera[:x], y-@window.height/2+@camera[:y]]
  end

  def world2screen x, y
    [x+@window.width/2-@camera[:x], y+@window.height/2-@camera[:y]]
  end

  def sq(x)
    x*x
  end

  def dist_sq x1, y1, x2, y2
    len_sq x1-x2,y1-y2
  end

  def len_sq x, y
    sq(x) + sq(y)
  end

  def dist x1, y1, x2, y2
    Math::sqrt(dist_sq(x1, y1, x2, y2))
  end

  def len x, y
    Math::sqrt(len_sq(x,y))
  end

  def dot x1, y1, x2, y2
    x1*x2 + y1*y2
  end

  def total_force e
    force = e[:force].dup
    if e[:driving_force]
      force[:x] += e[:driving_force][:x]
      force[:y] += e[:driving_force][:y]
    end
    if e[:friction]
      force[:x] += e[:friction][:x]
      force[:y] += e[:friction][:y]
    end
    force
  end

  def zero
    {:x => 0, :y => 0}
  end

  def lerp a, b, u
    a*u + b*(1.0-u)
  end

  def gen_player
    {
      :player => {:a => 200},
      :position => zero,
      :rotation => {:theta => 0},
      :driving_force => zero,
      :mass => 1,
      :friction => zero.merge({:c => 0.8}),
      :cam_follow => {:factor => @cam_follow_factor, :smoothing => 0.1},
      :collidable => {:radius => 9}
    }.merge(motion_components)
  end

  def motion_components
    {
      :velocity => zero,
      :acceleration => zero,
      :force => zero
    }
  end

  def gen_emitter
    {:period => 0.5, :velocity => 20, :lifetime => 3, :last_emit => 0, :variation => 0,
      :sprite => make_sprite(@particle)}
  end

  def make_sprite image, anchor={:x => 0.5, :y => 0.5}
    {:image => image, :anchor => anchor}
  end

  def get_chunks
    @engine.chunks
  end

  def enter_state
    @engine.each_entity :force do |e|
      e[:driving_force] = zero if e.include? :driving_force
    end
    @engine.unpause
  end

  def leave_state
    @engine.pause
  end

  def update
    super

    @window.caption = "fps: #{Gosu::fps.to_s}, c: #{@engine.total_chunks}, ac: #{@engine.active_chunks}, e: #{@engine.total_entities}, ae: #{@engine.active_entities}"
  end

end