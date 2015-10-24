class PostableImage < GameObject
  attr_reader :image_url
  attr_reader :url

  def initialize(image_url, url, x, y, z=0)
    super(x, y, z)
    @url = url
    @image_url = image_url
  end

  def dom_id
    "postable_image_#{x}_#{y}_#{z}"
  end

  def to_json
<<TXT
    {
      "dom_id": "#{dom_id}",
      "type": "postable_image",
      "image_url": "images/#{image_url}",
      "url": "#{url}",
      "x": #{x},
      "y": #{y},
      "z": #{z}
    }
TXT
  end
end
