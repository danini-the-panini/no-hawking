require 'gosu'

require_relative '../../engine/component'
require_relative 'letter'
require_relative '../physics'
require_relative '../../engine/matrix_hacks'

class LetterGun < Garbage::Component

  A_TO_Z = ('A'..'Z').to_a
  ALPHABET = A_TO_Z.map do |c|
    Gosu.const_get("Kb#{c}")
  end

  def initialize fire_rate, damage, speed
    @fire_rate = fire_rate
    @last_fire = 0
    @damage = damage
    @speed = speed

  end

  def update
    if (@engine.time-@last_fire > 1.0/@fire_rate)
      ALPHABET.each_with_index do |c, i|
        if @engine.button_down? c
          @last_fire = @engine.time
          make_letter A_TO_Z[i].downcase
          break
        end
      end
    end
  end

  private

    def make_letter l
      letter = Garbage::Renderable.new(
        Gosu::Image.from_text(@engine.window, l, Gosu::default_font_name, 20))
      letter.transform.position = @entity.transform.position
      letter.transform.rotation = @entity.transform.rotation
      physics = Physics.new
      physics.velocity = @entity.physics.velocity.normalized * @speed
      letter.add_component :physics, physics
      @engine.add_entity :letter, letter
    end
end
