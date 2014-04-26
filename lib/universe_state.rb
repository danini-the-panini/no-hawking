require_relative 'ingame_state'

class UniverseState < IngameState
  def initialize window, universe
    super window

    @engine
    .input_system(:down, :escape_universe, []) do |id|
      @window.change_state(:multiverse) if id == Gosu::KbEscape
    end

    universe.each do |e|
      @engine.add_entity e
    end
    
  end
end