require_relative 'ingame_state'

class UniverseState < IngameState
  def initialize window, universe
    super window

    universe.each do |e|
      @engine.add_entity e
    end
    
  end
end