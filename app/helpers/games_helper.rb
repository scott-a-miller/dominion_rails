module GamesHelper
  include Java

  def show_available_counts
    true
  end

  def card_name(card)
    card ? card.to_s.underscore : "blank"
  end

  def focus_card(card=nil)
    image_tag "medium/#{card_name(card)}-medium.png", :id=>'focused_card'
  end

  def small_card(card, x, y, gray=false, img_class="card")
    card_image(card, "small", x, y, gray)
  end

  def tiny_card(card, x, y, gray=false, img_class="card")
    card_image(card, "tiny", x, y, gray)
  end

  def card_image(card, size_name, x, y, gray=false, img_class="card")
    image_name = "#{size_name}/#{card_name(card)}-#{size_name}"
    image_name += gray ? "-gray.png" : ".png"

    image_tag image_name,
      :class=>img_class,
      :id=>"card_#{card.card_id}",
      :border=>"0",
      :style=>"top: #{y}px; left: #{x}px;"
  end

  def positioned_image(img, x, y)
    image_tag img,
      :border=>"0",
      :style=>"position:absolute; top: #{y}px; left: #{x}px;"
  end

  def played_card_location(index, total)
    card_width = 770 / total
    if card_width < 40
      card_width = 40
    elsif card_width > 77
      card_width = 77
    end
    [285 + (index * card_width), 325]
  end

  def hand_card_location(index, total)
    card_width = 770 / total
    if card_width < 40
      card_width = 40
    elsif card_width > 77
      card_width = 77
    end
    [285 + (index * card_width), 525]
  end

  def coin_image(value, x, y)
    positioned_image "#{value}-coin.png", x, y
  end

  def hand_image(value, x, y)
    if value >= 10
      positioned_image "plus-hand.png", x, y
    else
      positioned_image "#{value}-hand.png", x, y
    end
  end

  def points_image(value, x, y)
    bg_tag = positioned_image "points.png", x, y
    if value >= 0
      if value >= 10
        tens_tag = positioned_image("#{value / 10}-white.png", x+8, y+13)
        ones_tag = positioned_image("#{value % 10}-white.png", x+19, y+13)
        bg_tag + tens_tag + ones_tag
      else
        ones_tag = positioned_image("#{value % 10}-white.png", x+14, y+13)
        bg_tag + ones_tag
      end
    else
      bg_tag
    end
  end

  def deck_image(value, x, y)
    bg_tag = positioned_image "blank-deck.png", x, y
    if value >= 10
      tens_tag = positioned_image("#{value / 10}-white.png", x+9, y+17)
      ones_tag = positioned_image("#{value % 10}-white.png", x+19, y+17)
      bg_tag + tens_tag + ones_tag
    else
      ones_tag = positioned_image("#{value % 10}-white.png", x+14, y+17)
      bg_tag + ones_tag
    end
  end

  def discard_image(value, x, y)
    bg_tag = positioned_image "blank-discard.png", x, y
    if value >= 10
      tens_tag = positioned_image("#{value / 10}-white.png", x+7, y+14)
      ones_tag = positioned_image("#{value % 10}-white.png", x+16, y+14)
      bg_tag + tens_tag + ones_tag
    else
      ones_tag = positioned_image("#{value % 10}-white.png", x+12, y+14)
      bg_tag + ones_tag
    end
  end

  def number_image(value, x, y)
    if value < 5
      bg_tag = positioned_image "number.png", x, y
      if value >= 10
        tens_tag = positioned_image("#{value / 10}.png", x+2, y+5)
        ones_tag = positioned_image("#{value % 10}.png", x+12, y+5)
        bg_tag + tens_tag + ones_tag
      else
        ones_tag = positioned_image("#{value % 10}.png", x+7, y+5)
        bg_tag + ones_tag
      end
    else
      ""
    end
  end

  def selectable_card(card, x, y)
    link_to_function(tiny_card(card, x, y, true, "selectable_card"), "card_selected(this)")
  end

  def available?(card)
    @interface.available? card
  end
end
