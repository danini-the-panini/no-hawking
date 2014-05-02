require 'gosu'

module Tentative

  MILLISECOND = 0.001

  class Engine

    def initialize
      @last_time = Gosu::milliseconds
      @time = 0

      @systems = {:update => {}, :draw => {}, :once => {},
        :btn_up => {}, :btn_down => {}}

      @input_state = {}
    end

    def add_system type, name, node, &block
      @systems[type][name] = [node, block]
      self
    end

    def remove_system type, name
      @systems[type].delete name
    end

    def button_down
      ## TODO: loop through :btn_down systems
      @input_state[id] = true
    end

    def button_up
      ## TODO: loop through :btn_up systems
      @input_state[id] = false
    end

    def update
      @updating = true
      new_time = Gosu::milliseconds
      dt = (new_time-@last_time).to_f*MILLISECOND
      @time += dt
      @last_time = new_time

      ## TODO: loop through :update systems

      @updating = false
    end

    def draw
      ## TODO: loop though :draw systems
    end


  end

end