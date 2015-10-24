class SubmitSelectionImage < GameObject
  attr_reader :url
  attr_reader :selected_ids

  def initialize(url, selected_ids, x, y, z=0)
    super(x, y, z)
    @url = url
    @selected_ids = selected_ids
  end

  def dom_id
    "submit_selection_image"
  end

  def to_json
<<TXT
    {
      "dom_id": "#{dom_id}",
      "type": "submit_button",
      "image_url": "images/done.png",
      "selected_ids": "#{selected_ids}",
      "url": "#{url}",
      "x": #{x},
      "y": #{y},
      "z": #{z}
    }
TXT
  end
end
