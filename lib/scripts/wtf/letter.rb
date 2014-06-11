require_relative '../../engine/component'

class Letter < Garbage::Component
  def initialize letter
    @letter = letter
  end

  def value
    @letter
  end
end
