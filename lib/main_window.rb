require 'gosu'

class MainWindow < Gosu::Window

  def initialize width=800, height=600, fullscreen=false
    super

    @states = {}
    @current_state = nil

    self.caption = "No Hawking"
  end

  def change_state new_state
    @current_state.leave_state unless @current_state.nil?
    @current_state = @states[new_state]
    @current_state.enter_state
    self
  end

  def add_state name, state
    @states[name] = state

    change_state(name) if @change_state.nil?
    self
  end

  def remove_state name, state
    @states.delete name, state
    self
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