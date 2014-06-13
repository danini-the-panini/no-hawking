require 'matrix'

module Garbage
  class Component

    def on_hit other, point
    end

    %w(update).each do |meth|
      define_method(meth) { }
    end

    %w(button_down button_up).each do |meth|
      define_method(meth) { |id| }
    end

    def added_to entity, engine
      @entity = entity
      @engine = engine
    end

    # HELPERS
    def len_sq x, y
      x*x + y*y
    end

    def dot x1, y1, x2, y2
      x1*x2 + y1*y2
    end

    def sq x
      x*x
    end
  end
end
