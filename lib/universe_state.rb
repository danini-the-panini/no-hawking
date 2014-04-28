require_relative 'ingame_state'

class UniverseState < IngameState
  def initialize window, universe
    super window

    @spr_luna512 = Gosu::Image.new @window, "spr_luna512.png"

    @initial_hawking_cap = 1.0

    @collect_range = 50.0
    @collect_strength = 10.0
    @collect_threshold = 10.0

    @bullet_speed = 150.0
    @gun_damage = 0.1

    @engine
    .input_system(:down, :escape_universe, [:player]) do |id, e|
      if id == Gosu::KbSpace
        return_to_multiverse
        e.delete(:cam_follow)
        e.delete(:follow_mouse)
        e.delete(:player)
      end
    end
    .system(:update, :hawking_pull, [:player, :position, :hawking, :probe]) do |dt, t, e|
      @engine.each_entity([:hawking_pickup, :position, :driving_force]) do |h|
        dx = e[:position][:x]-h[:position][:x]
        dy = e[:position][:y]-h[:position][:y]

        factor = @collect_strength * (e[:hawking] >= e[:probe][:hawking_cap] ? -1 : 1)

        lsq = len_sq(dx,dy)
        if lsq < sq(@collect_range)
          len = Math::sqrt(lsq)
          ratio = 1.0-len/@collect_range
          h[:driving_force][:x] = (dx/len)*factor*ratio
          h[:driving_force][:y] = (dy/len)*factor*ratio
        else
          h[:driving_force][:x] = 0
          h[:driving_force][:y] = 0
        end
      end
      e
    end
    .system(:update, :hawking_collect, [:player, :hawking, :position]) do |dt, t, e|
      @engine.each_entity([:hawking_pickup, :position]) do |h|
        if dist_sq(h[:position][:x],h[:position][:y],e[:position][:x],e[:position][:y]) < sq(@collect_threshold)
          unless e[:hawking] >= e[:probe][:hawking_cap]
            e[:hawking] += h[:hawking_pickup]
            h[:delete] = true
          else
            e[:hawking] = e[:probe][:hawking_cap]
          end
        end
      end
      e
    end
    .system(:update, :hawking_bar, [:hawking_bar]) do |dt, t, e|
      @engine.each_entity([:player, :hawking, :probe]) do |pl|
        e[:scale][:x] = pl[:hawking]/pl[:probe][:hawking_cap]
      end
      e
    end
    .system(:update, :weapon, [:player, :probe]) do |dt, t, e|
      if @engine.down? Gosu::MsLeft
        mx, my = screen2world(@window.mouse_x, @window.mouse_y)
        rad = Math::atan2(my-e[:position][:y], mx-e[:position][:x])
        theta = (rad*180.0)/Math::PI
        @engine.add_entity(motion_components.merge({
          :position => e[:position].dup,
          :sprite => make_sprite(Gosu::Image.new @window, @particle),
          :rotation => {:theta => theta},
          :velocity => {x: @bullet_speed*Math.cos(rad) + e[:velocity][:x],
            :y => @bullet_speed*Math::sin(rad) + e[:velocity][:y] },
          :bullet => {:damage => @gun_damage, :owner => e[:id]},
          :life => 4, :lifetime => 4
        }))
      end
      e
    end
    .system(:update, :weapon_collision, [:bullet, :position]) do |dt, t, e|
      @engine.each_entity([:collidable, :position]) do |e2|
        unless e[:bullet][:owner] == e2[:id]
          if dist_sq(e[:position][:x],e[:position][:y],e2[:position][:x],e2[:position][:y]) < sq(e2[:collidable][:radius])
            e[:delete] = true
            # TODO: explosion
            unless e2[:health].nil?
              e2[:health] -= e[:bullet][:damage]
              if e2[:health] < 0
                e2[:delete] = true
                # TODO: bigger explosion
                # TODO: award XP / drop Hawking
              end
            end
          end
        end
      end
      e
    end
    .system(:update, :ai_target, [:enemy, :position]) do |dt, t, e|
      @engine.each_entity([:player, :position]) do |pl|
        dist_to_player = dist_sq(e[:position][:x],e[:position][:y],pl[:position][:x],pl[:position][:y])
        if dist_to_player < sq(e[:enemy][:alert_radius])
          e[:enemy][:target] = pl[:position].dup
          e[:enemy][:action] = dist_to_player < sq(e[:enemy][:attack_radius]) ? :attack : :hunt
        elsif e[:enemy][:target].nil? || dist_sq(e[:position][:x],e[:position][:y],e[:enemy][:target][:x],e[:enemy][:target][:y]) < sq(5)
          e[:enemy][:target] = {:x => e[:position][:x] + Gosu::random(-50,50),
            :y => e[:position][:y] + Gosu::random(-50,50)}
          e[:enemy][:action] = :move
        end
      end
      e
    end
    .system(:update, :ai_action, [:enemy, :position]) do |dt, t, e|
      @engine.each_entity([:player, :position]) do |pl|
        case e[:enemy][:action]
        when :move, :hunt
          e[:velocity][:x] = e[:enemy][:target][:x]-e[:position][:x]
          e[:velocity][:y] = e[:enemy][:target][:y]-e[:position][:y]
          if e[:enemy][:action] == :hunt
            vlen = len(e[:velocity][:x],e[:velocity][:y])
            vlen2 = vlen-(e[:enemy][:attack_radius]-5)
            e[:velocity][:x] *= vlen2/vlen
            e[:velocity][:y] *= vlen2/vlen
          end
          rad = Math::atan2(e[:velocity][:y], e[:velocity][:x])
          e[:rotation][:theta] = (rad/Math::PI)*180.0
        when :attack
          e[:velocity] = zero
          rad = Math::atan2(e[:enemy][:target][:y]-e[:position][:y],
            e[:enemy][:target][:x]-e[:position][:x])
          e[:rotation][:theta] = (rad/Math::PI)*180.0
          # TODO
        end
      end
    end
    .system(:update, :probe_life, [:player, :health]) do |dt, t, e|
      if e[:health] <= 0.0
        return_to_multiverse # TODO: animate explosion or something first
        remove e
      else
        e
      end
    end

    if universe.nil? || universe.empty?
      @engine
      .add_entity({
        :hud => true,
        :hawking_bar => true,
        :position => {:x => 10, :y => @window.height-10},
        :sprite => make_sprite((Gosu::Image.new @window, "hawking_bar.png"),{:x => 0.0, :y => 1.0}),
        :scale => {:x => 0.0, :y => 1.0}
      })
      .add_entity({
        :hud => true,
        :position => {:x => 10, :y => @window.height-10},
        :sprite => make_sprite((Gosu::Image.new @window, "hawking_bar_border.png"),{:x => 0.0, :y => 1.0})
      })
    else
      @engine.inject_state(universe)
      universe.each do |k,c|
        @visited_chunks[k] = true unless k == :default
      end
    end

    @engine
    .add_entity(
      gen_player.merge({
        :sprite => make_sprite(Gosu::Image.new @window, "spr_probe.png"),
        :hawking => 0.0,
        :health => 1.0,
        :probe => {:hawking_cap => @initial_hawking_cap, :xp => 0,
          :health_cap => 1.0, :armour_mult => 1.0, :speed_mult => 1.0}
      }))
    
  end

  def proc_gen xi, yi, chunk_size

    x1 = xi*chunk_size
    y1 = yi*chunk_size
    x2 = x1+chunk_size
    y2 = y1+chunk_size

    @engine
    .add_entity({
      :position => {:x => x1+chunk_size/2, :y => y1+chunk_size/2},
      :sprite => make_sprite(Gosu::Image.new @window, "dbg_chunk.png"),
      :norotate => true
    },[xi,yi])
    # .add_entity({
    #   :position => {:x => Gosu::random(xi,xj), :y => Gosu::random(yi,yj)},
    #   :sprite => make_sprite(Gosu::Image.from_text @window, "Random:#{Gosu::random(0,1000)}", Gosu::default_font_name, 50),
    #   :rotation => {:theta => Gosu::random(0,360)}
    # },[xi,yi])

    3.times do
      cx = Gosu::random(x1,x2)
      cy = Gosu::random(y1,y2)
      10.times do
        @engine.add_entity(gen_hawking_pickup(Gosu::random(-50,50)+cx, Gosu::random(-50,50)+cy),
          [xi,yi])
      end
    end

    moon_sqrt = 2
    step = chunk_size/moon_sqrt

    (x1...x2).step(step) do |sx|
      (y1...y2).step(step) do |sy|
        x = sx+Gosu::random(0,step)
        y = sy+Gosu::random(0,step)

        theta = Gosu::random(0,Math::PI*2)
        speed = Gosu::random(10,20)

        @engine.add_entity(
          gen_asteroid(x, y).merge({
            :velocity => {:x => Math::cos(theta)*speed, :y => Math::sin(theta)*speed}
          }), [xi,yi])
      end
    end

    10.times do
      @engine.add_entity({
        :position => {:x => Gosu::random(x1,x2), :y => Gosu::random(y1, y2)},
        :enemy => {:alert_radius => 300, :attack_radius => 100},
        :sprite => make_sprite(Gosu::Image.new @window, "spr_player.png"),
        :colour => 0xFFFF0000,
        :rotation => {:theta => Gosu::random(0,360)}
      }.merge(motion_components))
    end
  end

  def gen_hawking_pickup x, y
    scale = Gosu::random(0.7,1.8)
    shade = Gosu::random(0,1)
    {
      :position => {:x => x, :y => y},
      :sprite => make_sprite(Gosu::Image.new @window, "particle.png"),
      :scale => {x: scale, y: scale},
      :norotate => true,
      :hawking_pickup => scale*0.01,
      :mass => scale*0.01,
      :driving_force => zero,
      :friction => zero.merge({:c => 0.02}),
      :colour => Gosu::Color.rgba(lerp(255,162,shade).to_i,lerp(108,0,shade).to_i,
        lerp(0,255,shade).to_i,255)
    }.merge(motion_components)
  end

  def gen_asteroid x, y
    scale = Gosu::random(0.07,0.13)
    {
      :position => {:x => x, :y => y},
      :sprite => make_sprite(@spr_luna512),
      :scale => {:x => scale, :y => scale},
      :norotate => true,
      :mass => scale*10,
      :driving_force => zero,
      :collidable => {:radius => (@spr_luna512.width/2.0)*scale}
    }.merge(motion_components)
  end

  def return_to_multiverse
    @window.change_state(:multiverse)
  end

  def get_hawking
    @engine.each_entity([:player, :hawking]) do |pl|
      return pl[:hawking]
    end
  end
end