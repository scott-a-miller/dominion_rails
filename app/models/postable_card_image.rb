class PostableCardImage < GameObject
  def PostableCardImage.small_card(card, url, x, y, z=0)
    PostableCardImage.new(card, url, "small", x, y, z)
  end

  def PostableCardImage.tiny_card(card, url, x, y, z=0)
    PostableCardImage.new(card, url, "tiny", x, y, z)
  end

  attr_reader :size_name
  attr_reader :url

  def initialize(card, url, size_name, x, y, z=0)
    super(x, y, z)
    @card = card
    @size_name = size_name
    @url = url
  end

  def dom_id
    "postable_card_image_#{x}_#{y}_#{z}_#{size_name}"
  end

  def card_id
    @card.card_id
  end

  def image_url
    "images/#{size_name}/#{card_name}-#{size_name}.png"
  end

  def card_name
    @card ? @card.to_s.underscore : "blank"
  end

  def to_json
<<TXT
    {
      "dom_id": "#{dom_id}",
      "type": "postable_image",
      "image_url": "#{image_url}",
      "url": "#{url}",
      "card_id": "#{card_id}",
      "x": #{x},
      "y": #{y},
      "z": #{z}
    }
TXT
  end
end
