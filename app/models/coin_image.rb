class CoinImage < GameObject
  attr_reader :value

  def initialize(x, y, value, z=1)
    super(x, y, z)
    @value = value
  end

  def dom_id
    "coin_image_#{x}_#{y}_#{z}"
  end

  def image_url
    "images/#{value}-coin.png"
  end

  def to_json
<<TXT
    {
      "dom_id": "#{dom_id}",
      "type": "image",
      "image_url": "#{image_url}",
      "x": #{x},
      "y": #{y},
      "z": #{z}
    }
TXT
  end

end
