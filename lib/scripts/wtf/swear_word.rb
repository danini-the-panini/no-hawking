require_relative '../../engine/component'

class SwearWord < Garbage::Component
  def initialize word
    @word = word
    @buff = 0
  end

  def on_hit other, point
    if other.has_component? :letter
      @entity.destroy!
#      if @word[@buff] == other.letter.value
        #@buff += 1
        #if @buff >= @word.length
          #@entity.destroy!
          #TODO: make explosion
        #end
      #end
    end
  end
end
