require_relative 'ingame_state'

class UniverseState < IngameState
  def initialize window, universe
    super window

    @engine
    .input_system(:down, :escape_universe, []) do |id|
      return_to_multiverse if id == Gosu::KbSpace
    end
    .system(:update, :probe_life, [:probe]) do |dt, t, e|
      if e[:probe][:health] <= 0.0
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
        :player => {:a => 30},
        :sprite => ECS::make_sprite(Gosu::Image.new @window, "spr_player.png"),
        :probe => {:hawking => 0, :hawking_cap => @initial_hawking_cap, :xp => 0,
          :health => 1.0, :health_cap => 1.0, :armour_mult => 1.0,
          :speed_mult => 1.0}
      }))
    
  end

  def return_to_multiverse
    @window.change_state(:multiverse)
  end
end