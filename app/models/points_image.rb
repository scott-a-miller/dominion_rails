class PointsImage < GameObject
  attr_reader :points

  def initialize(x, y, points, z=0)
    super(x, y, z)
    @points = points
  end

  def digit_to_json(dx, dy, value)
<<TXT
    {
      "dom_id": "points_#{dx}_#{dy}_#{z}",
      "type": "image",
      "image_url":"images/#{value}-white.png",
      "x": #{dx},
      "y": #{dy},
      "z": #{z}
    }
TXT
  end

  def to_json
    objs = []
    objs <<
<<TXT
    {
      "dom_id": "points_bg_#{x}_#{y}_#{z}",
      "type": "image",
      "image_url": "images/points.png",
      "x": #{x},
      "y": #{y},
      "z": #{z}
    }
TXT

    if points >= 10
      objs << digit_to_json(x+8, y+13, points / 10)
      objs << digit_to_json(x+19, y+13, points % 10)
    else
      objs << digit_to_json(x+14, y+13, points)
    end

    objs.join(",\n")
  end
end
