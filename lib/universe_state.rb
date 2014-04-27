require_relative 'ingame_state'

class UniverseState < IngameState
  def initialize window, universe
    super window

    @initial_hawking_cap = 1.0

    @engine
    .input_system(:down, :escape_universe, []) do |id|
      return_to_multiverse if id == Gosu::KbSpace
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

    universe.each do |e|
      @engine.add_entity e
    end

    @engine
    .add_entity(
      gen_player.merge({
        :sprite => make_sprite(Gosu::Image.new @window, "spr_player.png"),
        :hawking => 0.0,
        :health => 1.0,
        :probe => {:hawking_cap => @initial_hawking_cap, :xp => 0,
          :health_cap => 1.0, :armour_mult => 1.0, :speed_mult => 1.0}
      }))
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
    
  end

  def proc_gen xi, yi
    @engine
    .add_entity({
      :position => {:x => (xi+Gosu::random(0,1))*@chunk_size, :y => (yi+Gosu::random(0,1))*@chunk_size},
      :sprite => make_sprite(Gosu::Image.from_text @window, "Random:#{Gosu::random(0,1000)}", Gosu::default_font_name, 50),
      :rotation => {:theta => Gosu::random(0,360)}
    })
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