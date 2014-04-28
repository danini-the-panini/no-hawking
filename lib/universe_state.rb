require_relative 'ingame_state'

class UniverseState < IngameState
  def initialize window, universe
    super window

    @spr_luna512 = Gosu::Image.new @window, "spr_luna512.png"

    @initial_hawking_cap = 1.0

    @collect_range = 50.0
    @collect_strength = 10.0
    @collect_threshold = 10.0

    @engine
    .input_system(:down, :escape_universe, [:player]) do |id, e|
      if id == Gosu::KbSpace
        return_to_multiverse
        e.delete(:follow_mouse)
        e.delete(:player)
      end
    end
    .system(:update, :hawking_pull, [:player, :hawking]) do |dt, t, e|
      @engine.each_entity([:hawking_pickup, :driving_force]) do |h|
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
    .system(:update, :hawking_collect, [:player, :hawking]) do |dt, t, e|
      @engine.each_entity([:hawking_pickup, :driving_force]) do |h|
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
      .add_entity({
        :visited => {},
        :chunk_size => 1000
      })
    else
      universe.each do |e|
        @engine.add_entity e
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

  def proc_gen xi, yi, xj, yj
    range_x = xj-xi
    range_y = yj-yi

    @engine
    .add_entity({
      :position => {:x => Gosu::random(xi,xj), :y => Gosu::random(yi,yj)},
      :sprite => make_sprite(Gosu::Image.from_text @window, "Random:#{Gosu::random(0,1000)}", Gosu::default_font_name, 50),
      :rotation => {:theta => Gosu::random(0,360)}
    })
    # .add_entity({
    #   :position => {:x => xi+range_x/2, :y => yi+range_y/2},
    #   :sprite => make_sprite(Gosu::Image.new @window, "dbg_chunk.png"),
    #   :norotate => true
    # })

    3.times do
      cx = Gosu::random(xi,xj)
      cy = Gosu::random(yi,yj)
      10.times do
        @engine.add_entity(gen_hawking_pickup(Gosu::random(-50,50)+cx, Gosu::random(-50,50)+cy))
      end
    end

    moon_sqrt = 2
    step_x = range_x/moon_sqrt
    step_y = range_y/moon_sqrt

    (xi...xj).step(step_x) do |sx|
      (yi...yj).step(step_y) do |sy|
        x = sx+Gosu::random(0,step_x)
        y = sy+Gosu::random(0,step_y)

        theta = Gosu::random(0,Math::PI*2)
        speed = Gosu::random(10,20)

        @engine.add_entity(
          gen_asteroid(x, y).merge({
            :velocity => {:x => Math::cos(theta)*speed, :y => Math::sin(theta)*speed}
          }))
      end
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