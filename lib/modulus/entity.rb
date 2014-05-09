require_relative 'utility'

class Entity
  include Utility

  def initialize engine
    @engine = engine
  end

  def update dt, t
  end

  def draw window
  end

end