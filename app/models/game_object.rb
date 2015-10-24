class GameObject
  attr_reader :x
  attr_reader :y
  attr_reader :z

  def initialize(x, y, z=0)
    @x = x
    @y = y
    @z = z
  end
end
