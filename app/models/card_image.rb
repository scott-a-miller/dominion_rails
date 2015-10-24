class CardImage < GameObject
  def CardImage.small_card(card, x, y, enabled=true, selectable=false, z=0)
    CardImage.new(card, "small", x, y, enabled, selectable, z)
  end

  def CardImage.tiny_card(card, x, y, enabled=true, selectable=false, z=0)
    CardImage.new(card, "tiny", x, y, enabled, selectable, z)
  end

  attr_reader :size_name
  attr_reader :enabled
  attr_reader :selectable

  def initialize(card, size_name, x, y, enabled=true, selectable=false, z=0)
    super(x, y, z)
    @card = card
    @size_name = size_name
    @enabled = enabled
    @selectable = !!selectable
  end

  def dom_id
    dom_id = "card_image_#{x}_#{y}_#{z}_#{size_name}"
    if selectable
      dom_id += "_selectable"
    end
    dom_id
  end

  def card_id
    @card.card_id
  end

  def image_url
    "images/#{size_name}/#{card_name}-#{size_name}" + (enabled ? ".png" : "-gray.png")
  end

  def card_name
    @card ? @card.to_s.underscore : "blank"
  end

  def to_json
<<TXT
    {
      "dom_id": "#{dom_id}",
      "type": "#{selectable ? "selectable_image" : "image"}",
      "image_url": "#{image_url}",
      "card_id": "#{card_id}",
      "enabled": #{enabled},
      "x": #{x},
      "y": #{y},
      "z": #{z}
    }
TXT
  end
end
