class PanelObject < GameObject
  attr_reader :width
  attr_reader :height

  def initialize(x, y, width, height, z)
    super(x, y, z)
    @width = width
    @height = height
  end

  def dom_id
    "panel_#{x}_#{y}_#{z}"
  end

  def to_json
<<TXT
    {
      "dom_id": "#{dom_id}",
      "type": "panel",
      "x": #{x},
      "y": #{y},
      "z": #{z},
      "height": #{height},
      "width": #{width}
    }
TXT
  end
end
