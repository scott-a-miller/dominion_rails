class DeckImage < GameObject
  attr_reader :card_count

  def initialize(x, y, card_count, z=0)
    super(x, y, z)
    @card_count = card_count
  end

  def digit_to_json(dx, dy, card_count)
<<TXT
    {
      "dom_id": "deck_#{dx}_#{dy}_#{z}",
      "type": "image",
      "image_url":"images/#{card_count}-white.png",
      "x": #{dx},
      "y": #{dy}
    }
TXT
  end

  def to_json
    objs = []
    objs <<
<<TXT
    {
      "dom_id": "deck_bg_#{x}_#{y}_#{z}",
      "type": "image",
      "image_url": "images/blank-deck.png",
      "x": #{x},
      "y": #{y},
      "z": #{z}
    }
TXT

    if card_count >= 10
      objs << digit_to_json(x+9, y+17, card_count / 10)
      objs << digit_to_json(x+19, y+17, card_count % 10)
    else
      objs << digit_to_json(x+14, y+17, card_count)
    end

    objs.join(",\n")
  end
end
