class MessageObject < GameObject
  attr_reader :message
  def initialize(x, y, message, z=0)
    super(x, y, z)
    @message = message
  end

  def dom_id
    "message_#{x}_#{y}_#{z}"
  end

  def to_json
<<TXT
    {
      "dom_id": "#{dom_id}",
      "type": "message",
      "text": "#{message}",
      "x": #{x},
      "y": #{y},
      "z": #{z}
    }
TXT
  end
end
