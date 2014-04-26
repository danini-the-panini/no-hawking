require 'gosu'

class MainWindow < Gosu::Window

  def initialize width=800, height=600, fullscreen=false
    super

    @states = {}
    @current_state = nil
  end

  def change_state new_state
    @current_state.leave_state unless @change_state.nil?
    @current_state = @states[new_state]
    @current_state.enter_state
  end

  def add_state name, state
    @states[name] = state

    change_state(name) if @change_state.nil?
  end

  def remove_state name, state
    @states.delete name, state
  end

  def button_down id
    @current_state.button_down(id) if @current_state
  end

  def button_up id
    @current_state.button_up(id) if @current_state
  end

  def update
    @current_state.update if @current_state
  end

  def draw
    @current_state.draw if @current_state
  end

end