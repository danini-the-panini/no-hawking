require_relative '../../engine/component'

class SwearWord < Garbage::Component
  def initialize word
    @word = word
    @buff = 0
  end

  def on_hit other
    if other.has_component? :letter
      if @word[@buff] == other.letter.value
        @buff += 1
        if @buff >= @word.length
          self.destroy!
          # TODO: make explosion
        end
      end
    end
  end
end
