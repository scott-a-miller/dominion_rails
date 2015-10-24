class NumberImage < GameObject
  attr_reader :value

  def initialize(x, y, value, z=1)
    super(x, y, z)
    @value = value
  end

  def digit_to_json(dx, dy, value)
<<TXT
    {
      "dom_id": "number_#{dx}_#{dy}_#{z}",
      "type": "image",
      "image_url": "images/#{value}.png",
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
      "dom_id": "number_bg_#{x}_#{y}_#{z}",
      "type": "image",
      "image_url": "images/number.png",
      "x": #{x},
      "y": #{y},
      "z": #{z}
    }
TXT

    if value >= 10
      objs << digit_to_json(x+2, y+5, value / 10)
      objs << digit_to_json(x+12, y+5, value % 10)
    else
      objs << digit_to_json(x+7, y+5, value)
    end

    objs.join(",\n")
  end
end
