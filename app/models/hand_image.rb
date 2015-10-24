class HandImage < GameObject
  attr_reader :card_count

  def initialize(x, y, card_count, z=0)
    super(x, y, z)
    @card_count = card_count
  end

  def dom_id
    "hand_image_#{x}_#{y}_#{z}"
  end

  def image_url
    if card_count >= 10
      "plus-hand.png"
    else
      "#{card_count}-hand.png"
    end
  end

  def to_json
<<TXT
    {
      "dom_id": "#{dom_id}",
      "type": "image",
      "image_url": "images/#{image_url}",
      "x": #{x},
      "y": #{y},
      "z": #{z}
    }
TXT
  end

end
