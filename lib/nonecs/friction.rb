module Friction

  def do_friction dt, t
    @force[:x] += -@friction*@velocity[:x]
    @force[:y] += -@friction*@velocity[:y]
  end

end