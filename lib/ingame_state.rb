require_relative 'engine_state'

class IngameState < EngineState
  def initialize window
    super

    @particle = Gosu::Image.new @window, "particle.png"

    @engine
    .input_system(:down, :pcontrol, [:player,:acceleration]) do |id, e|
      case id
      when Gosu::KbA
        e[:acceleration][:x] -= e[:player][:a]
      when Gosu::KbD
        e[:acceleration][:x] += e[:player][:a]
      when Gosu::KbW
        e[:acceleration][:y] -= e[:player][:a]
      when Gosu::KbS
        e[:acceleration][:y] += e[:player][:a]
      end
    end
    .input_system(:up, :pcontrol, [:player,:velocity]) do |id, e|
      case id
      when Gosu::KbA
        e[:acceleration][:x] += e[:player][:a]
      when Gosu::KbD
        e[:acceleration][:x] -= e[:player][:a]
      when Gosu::KbW
        e[:acceleration][:y] += e[:player][:a]
      when Gosu::KbS
        e[:acceleration][:y] -= e[:player][:a]
      end
    end
    .system(:draw, :sprite_draw_rotated, [:position, :sprite, :rotation]) do |e|
      @window::translate(*world2screen(0,0)) do
        x = e[:position][:x]
        y = e[:position][:y]
        img = e[:sprite][:image]
        dx = e[:sprite][:anchor][:x]
        dy = e[:sprite][:anchor][:y]
        img.draw_rot x, y, 0, e[:rotation][:theta], dx, dy
      end
    end
    .system(:draw, :sprite_draw, [:position, :sprite, :norotate]) do |e|
      @window::translate(*world2screen(0,0)) do
        x = e[:position][:x]
        y = e[:position][:y]
        img = e[:sprite][:image]
        dx = e[:sprite][:anchor][:x]*img.width
        dy = e[:sprite][:anchor][:y]*img.height
        img.draw x-dx, y-dy, 0
      end
    end
    .system(:update, :acceleration, [:velocity, :acceleration]) do |dt, t, e|
      e[:velocity][:x] += e[:acceleration][:x]*dt
      e[:velocity][:y] += e[:acceleration][:y]*dt
      e
    end
    .system(:update, :movement, [:position, :velocity]) do |dt, t, e|
      e[:position][:x] += e[:velocity][:x]*dt
      e[:position][:y] += e[:velocity][:y]*dt
      e
    end
    .system(:draw, :particle, [:position, :sprite, :life, :lifetime]) do |e|
      @window::translate(*world2screen(0,0)) do
        x = e[:position][:x]
        y = e[:position][:y]
        img = e[:sprite][:image]
        dx = e[:sprite][:anchor][:x]*img.width
        dy = e[:sprite][:anchor][:y]*img.height
        img.draw x-dx, y-dy, 0, 1, 1, (((e[:life]/e[:lifetime])*0xFF).to_i << 24) | 0x00FFFFFF, :additive
      end
    end
    .system(:update, :emitter, [:emitter, :position]) do |dt, t, e|
      if t-e[:emitter][:last_emit] > e[:emitter][:period]
        theta = Gosu::random(0,360)

        @engine.add_entity({
          :position => e[:position].dup,
          :velocity => {:x => e[:emitter][:velocity]*Math::cos(theta),
            :y => e[:emitter][:velocity]*Math::sin(theta)},
          :life => e[:emitter][:lifetime],
          :lifetime => e[:emitter][:lifetime],
          :sprite => e[:emitter][:sprite]
        })
      end
      e
    end
    .system(:update, :life, [:life]) do |dt, t, e|
      e[:life] -= dt
      e[:life] < 0 ? remove(e) : e
    end
    .system(:update, :follow_mouse, [:position, :rotation, :follow_mouse]) do |dt, t, e|
      mx, my = screen2world(@window.mouse_x, @window.mouse_y)
      rad = Math::atan2(my-e[:position][:y], mx-e[:position][:x])
      e[:rotation][:theta] = (rad*180.0)/Math::PI
      e
    end
    .system(:update, :cursor, [:position, :cursor]) do |dt, t, e|
      mx, my = screen2world(@window.mouse_x, @window.mouse_y)
      e[:position][:x] = mx
      e[:position][:y] = my
      e
    end
    .add_entity({
      :cursor => true,
      :sprite => ECS::make_sprite(Gosu::Image.new @window, "cursor.png"),
      :position => {:x => 0, :y => 0},
      :norotate => true
    })
  end

  def remove e
    e.merge({:delete => true})
  end

  def screen2world x, y
    [x-@window.width/2, y-@window.height/2]
  end

  def world2screen x, y
    [x+@window.width/2, y+@window.height/2]
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

  def gen_player
    {
      :player => {},
      :follow_mouse => {},
      :sprite => {},
      :position => {:x => 0, :y => 0},
      :rotation => {:theta => 0},
      :velocity => {:x => 0, :y => 0},
      :acceleration => {:x => 0, :y => 0},
      :force => {:x => 0, :y => 0}
    }
  end

  def gen_emitter
    {:period => 0.5, :velocity => 20, :lifetime => 3, :last_emit => 0, :variation => 0,
      :sprite => ECS::make_sprite(@particle)}
  end

end