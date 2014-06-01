module Garbage
  class Component
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
  end
end
