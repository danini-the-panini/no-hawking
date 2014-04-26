require 'gosu'
require_relative 'main_window'
require_relative 'start_state'

main_window = MainWindow.new

start_state = StartState.new main_window

main_window.add_state :start, start_state

main_window.show