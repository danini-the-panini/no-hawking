require_relative 'ingame_state'

class UniverseState < IngameState
  def initialize window, universe
    super window

    @music = Gosu::Song.new @window, "mus/Tense Ambient.ogg"

    @lose_your_shit_on_death = true

    @spr_luna512 = Gosu::Image.new @window, "celestialbodies/spr_luna1_512.png"
    @spr_alien = Gosu::Image.new @window, "actors/spr_alien.png"
    @spr_shield = Gosu::Image.new @window, "actors/spr_shield.png"

    @spr_bar_hp = Gosu::Image.new @window, "ui/spr_bar_hp.png"
    @spr_bar_xp = Gosu::Image.new @window, "ui/spr_bar_xp.png"

    @spr_particle = Gosu::Image.new @window, "effects/spr_particle.png"

    @initial_hawking_cap = 1.0

    @collect_range = 50.0
    @collect_strength = 10.0
    @collect_threshold = 10.0

    @player_fire_rate = 5.0
    @player_bullet_speed = 300.0
    @player_damage = 0.1

    @enemy_fire_rate = 10.0
    @enemy_bullet_speed = 250.0
    @enemy_damage = 0.1

    @spr_bullet = Gosu::Image.new @window, "actors/spr_bullet.png"

    @engine
    .add_system(:btn_down, :escape_universe, :player) do |e, id|
      if id == Gosu::KbSpace
        return_to_multiverse
        # e.delete(:cam_follow)
        # e.delete(:follow_mouse)
        # e.delete(:player)
      end
    end
    .add_system(:update, :hawking_pull, :player) do |e, dt, t|
      @engine.each_entity(:hawking_pickup) do |h|
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
    end
    .add_system(:update, :hawking_collect, :player) do |e, dt, t|
      @engine.each_entity(:hawking_pickup) do |h|
        if dist_sq(h[:position][:x],h[:position][:y],e[:position][:x],e[:position][:y]) < sq(@collect_threshold)
          unless e[:hawking] >= e[:probe][:hawking_cap]
            e[:hawking] += h[:hawking_pickup]
            @engine.remove_entity h, :all
          else
            e[:hawking] = e[:probe][:hawking_cap]
          end
        end
      end
    end
    .add_system(:update, :hawking_bar, :hawking_bar) do |e, dt, t|
      @engine.each_entity :player do |pl|
        e[:scale][:x] = (300.0*pl[:hawking]/pl[:probe][:hawking_cap])/16.0
      end
    end
    .add_system(:update, :health_bar, :health_bar) do |e, dt, t|
      @engine.each_entity :player do |pl|
        e[:scale][:x] = (250.0*pl[:health]/pl[:probe][:health_cap])/16.0
      end
    end
    .add_system(:update, :weapon, :player) do |e, dt, t|
      if @engine.down?(Gosu::MsLeft) && (t-e[:weapon][:last_fire] > 1.0/e[:weapon][:fire_rate])
        e[:weapon][:last_fire] = t
        mx, my = screen2world(@window.mouse_x, @window.mouse_y)
        rad = Math::atan2(my-e[:position][:y], mx-e[:position][:x])
        theta = (rad*180.0)/Math::PI
        @engine.add_entity(motion_components.merge({
          :position => e[:position].dup,
          :sprite => make_sprite(Gosu::Image.new @window, @spr_bullet),
          :rotation => {:theta => theta},
          :velocity => {x: e[:weapon][:speed]*Math.cos(rad) + e[:velocity][:x],
            :y => e[:weapon][:speed]*Math::sin(rad) + e[:velocity][:y] },
          :bullet => {:damage => e[:weapon][:damage], :owner => e[:id]},
          :life => 4, :lifetime => 4
        }), :bullet, :velocity, :drawable)
      end
    end
    .add_system(:update, :weapon_collision, :bullet) do |e, dt, t|
      @engine.each_entity(:collidable) do |e2|
        unless e[:bullet][:owner] == e2[:id]
          if dist_sq(e[:position][:x],e[:position][:y],e2[:position][:x],e2[:position][:y]) < sq(e2[:collidable][:radius])
            @engine.remove_entity e, :all
            # TODO: explosion
            unless e2[:health].nil?
              e2[:health] -= e[:bullet][:damage]
            end
          end
        end
      end
    end
    .add_system(:update, :ai_target, :enemy) do |e, dt, t|
      @engine.each_entity :player do |pl|
        dist_to_player = dist_sq(e[:position][:x],e[:position][:y],pl[:position][:x],pl[:position][:y])
        if dist_to_player < sq(e[:enemy][:alert_radius])
          e[:enemy][:target] = {:x => pl[:position][:x] + pl[:velocity][:x]*0.016,
            :y => pl[:position][:y] + pl[:velocity][:y]*0.016}
          e[:enemy][:action] = dist_to_player < sq(e[:enemy][:attack_radius]) ? :attack : :hunt
        elsif e[:enemy][:target].nil? || dist_sq(e[:position][:x],e[:position][:y],e[:enemy][:target][:x],e[:enemy][:target][:y]) < sq(5)
          e[:enemy][:target] = {:x => e[:position][:x] + Gosu::random(-50,50),
            :y => e[:position][:y] + Gosu::random(-50,50)}
          e[:enemy][:action] = :move
        end
      end
    end
    .add_system(:update, :ai_action, :enemy) do |e, dt, t|
      e[:velocity][:x] = e[:enemy][:target][:x]-e[:position][:x]
      e[:velocity][:y] = e[:enemy][:target][:y]-e[:position][:y]

      case e[:enemy][:action]
      when :hunt, :attack
        vlen = len(e[:velocity][:x],e[:velocity][:y])
        vlen2 = vlen-(e[:enemy][:attack_radius]/2.0)
        e[:velocity][:x] *= vlen2/vlen
        e[:velocity][:y] *= vlen2/vlen
      end
      rad = Math::atan2(e[:velocity][:y], e[:velocity][:x])
      e[:rotation][:theta] = (rad/Math::PI)*180.0

      if e[:enemy][:action] == :attack && (t-e[:weapon][:last_fire] > 1.0/e[:weapon][:fire_rate])
        e[:weapon][:last_fire] = t
        @engine.add_entity(motion_components.merge({
          :position => e[:position].dup,
          :sprite => make_sprite(Gosu::Image.new @window, @spr_bullet),
          :rotation => {:theta => e[:rotation][:theta]},
          :velocity => {x: e[:weapon][:speed]*Math.cos(rad) + e[:velocity][:x],
            :y => e[:weapon][:speed]*Math::sin(rad) + e[:velocity][:y] },
          :bullet => {:damage => e[:weapon][:damage], :owner => e[:id]},
          :life => 4, :lifetime => 4,
          :colour => 0xFFFF0000
        }), :bullet, :velocity, :drawable)
      end
    end
    .add_system(:update, :enemy_life, :enemy) do |e, dt, t|
      if e[:health] < 0
        @engine.remove_entity e, :all
        # TODO: bigger explosion
        # TODO: award XP / drop Hawking ?
      end
    end
    .add_system(:update, :probe_life, :player) do |e, dt, t|
      unless e[:health] > 0
        if @lose_your_shit_on_death
          e[:hawking] = 0
        end
        return_to_multiverse # TODO: animate explosion or something first
        @engine.remove_entity e, :all
      end
    end
    .add_system(:update, :shield_follow, :component) do |e, dt, t|
      @engine.each_entity :player do |pl|
        e[:position][:x] = pl[:position][:x]
        e[:position][:y] = pl[:position][:y]
      end
      e
    end

    if universe.nil? || universe.empty?
      @engine
      .add_entity({
        :position => {:x => @window.width/2, :y => 10},
        :sprite => make_sprite((@spr_bar_bg),{:x => 0.5, :y => 0.0}),
        :scale => {:x => 300.0/16.0, :y => 1.0}
      }, :hud)
      .add_entity({
        :hawking_bar => true,
        :position => {:x => @window.width/2, :y => 10},
        :sprite => make_sprite((@spr_bar_hawking),{:x => 0.5, :y => 0.0}),
        :scale => {:x => 0.0, :y => 1.0}
      }, :hud, :hawking_bar)
      .add_entity({
        :position => {:x => @window.width/2, :y => 30},
        :sprite => make_sprite((@spr_bar_bg),{:x => 0.5, :y => 0.0}),
        :scale => {:x => 250.0/16.0, :y => 1.0}
      }, :hud)
      .add_entity({
        :health_bar => true,
        :position => {:x => @window.width/2, :y => 30},
        :sprite => make_sprite((@spr_bar_hp),{:x => 0.5, :y => 0.0}),
        :scale => {:x => 0.0, :y => 1.0}
      }, :hud, :health_bar)
      .add_entity({
        :position => zero,
        :sprite => make_sprite(@spr_shield),
      }, :component, :drawable)
    else
      @engine.inject_state(universe)
      universe.each do |k,c|
        @visited_chunks[k] = true unless k == :default
      end
    end

    @engine
    .add_entity(
      gen_player.merge({
        :sprite => make_sprite(@spr_probe),
        :hawking => 0.0,
        :health => 1.0,
        :probe => {:hawking_cap => @initial_hawking_cap, :xp => 0,
          :health_cap => 1.0, :armour_mult => 1.0, :speed_mult => 1.0},
        :weapon => {:fire_rate => @player_fire_rate, :last_fire => 0,
          :damage => @player_damage, :speed => @player_bullet_speed}
      }), :player, :collidable, :force, :acceleration, :velocity, :friction, :cam_follow,
        :follow_mouse, :drawable)

    
  end

  def proc_gen xi, yi, chunk_size
    x1 = xi*chunk_size
    y1 = yi*chunk_size
    x2 = x1+chunk_size
    y2 = y1+chunk_size

    chunk_name = [xi,yi]

    # @engine
    # .add_entity_to_chunk({
    #   :position => {:x => x1+chunk_size/2, :y => y1+chunk_size/2},
    #   :sprite => make_sprite(Gosu::Image.new @window, "dbg_chunk.png"),
    # }, chunk_name, :drawable)
    # .add_entity_to_chunk({
    #   :position => {:x => Gosu::random(xi,xj), :y => Gosu::random(yi,yj)},
    #   :sprite => make_sprite(Gosu::Image.from_text @window, "Random:#{Gosu::random(0,1000)}", Gosu::default_font_name, 50),
    #   :rotation => {:theta => Gosu::random(0,360)}
    # }, [xi,yi], :drawable)

    3.times do
      cx = Gosu::random(x1,x2)
      cy = Gosu::random(y1,y2)
      10.times do
        @engine.add_entity_to_chunk(
          gen_hawking_pickup(
            Gosu::random(-50,50)+cx, Gosu::random(-50,50)+cy), chunk_name,
          :hawking_pickup, :driving_force, :force, :acceleration, :velocity, :friction, :drawable)
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

        @engine.add_entity_to_chunk(
          gen_asteroid(x, y).merge({
            :velocity => {:x => Math::cos(theta)*speed, :y => Math::sin(theta)*speed}
          }), chunk_name, :collidable, :force, :acceleration, :velocity, :drawable)
      end
    end

    5.times do
      ex = Gosu::random(x1,x2)
      ey = Gosu::random(y1, y2)
      @engine.add_entity({
        :position => {:x => ex, :y => ey},
        :enemy => {:alert_radius => 300, :attack_radius => 100,
          :target => {:x => ex, :y => ey}},
        :sprite => make_sprite(@spr_alien),
        :colour => 0xFFFF0000,
        :rotation => {:theta => Gosu::random(0,360)},
        :collidable => {:radius => 12},
        :health => 0.5,
        :weapon => {:fire_rate => @enemy_fire_rate, :last_fire => 0,
          :damage => @enemy_damage, :speed => @enemy_bullet_speed}
      }.merge(motion_components), :enemy, :collidable, :acceleration, :velocity, :drawable)
    end
  end

  def gen_hawking_pickup x, y
    scale = Gosu::random(0.7,1.8)
    shade = Gosu::random(0,1)
    {
      :position => {:x => x, :y => y},
      :sprite => make_sprite(@spr_particle),
      :scale => {x: scale, y: scale},
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
      :mass => scale*10,
      :driving_force => zero,
      :collidable => {:radius => (@spr_luna512.width/2.0)*scale},
      :health => 10
    }.merge(motion_components)
  end

  def return_to_multiverse
    @window.change_state(:multiverse)
  end

  def get_hawking
    @engine.each_entity(:player) do |pl|
      return pl[:hawking]
    end
  end

  def get_state
    @engine.nodes
  end
  
  def enter_state
    @music.play true
  end

  def leave_state
    @music.stop
  end
end