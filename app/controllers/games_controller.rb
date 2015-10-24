require 'game_server'

class GamesController < ApplicationController
  GameStateEvent = com.brokenmodel.dominion.GameStateEvent

  before_filter :login_required
  before_filter :game_state, :except=>[:new_game]

  def index
    @game_events = []
    while event = @interface.pop_event
      @game_events << event
    end

    @objects = []
    @events = []
    add_player_states
    add_available_cards
    add_hand_cards
    add_played_cards
    add_question_cards
    add_events
  end

  def update
    if @turn_state
      @game_events = []
      while event = @interface.pop_event
        @game_events << event
      end

      @objects = []
      @events = []
      add_player_states
      add_available_cards
      add_hand_cards
      add_played_cards
      add_question_cards
      add_events
      objects_string = @objects.map{|v|v.to_json}.join(", ")
      events_string = @events.reverse.map{|list|
        "[" + list.map{|v| v.to_json}.join(",") + "]"
      }.join(", ")
    else
      objects_string = ""
      events_string = ""
    end
    render :text=>"[[#{objects_string}],[#{events_string}]]"
  end

  def send_message
    if @turn_state
      if params[:message]
        @interface.send_message(CGI.escapeHTML(params[:message]))
      end
    end
    render :text=>"\"Sent #{params[:message]}\""
  end

  def new_game
    DominionGameServer.exit_game(current_user.id)
    redirect_to :controller=>:lobby, :action=>:index
  end

  def exception
    @message = @interface.exception_message
  end

  def card_to_gain
    if (params[:card_id] == "None")
      @interface.selected_cards = []
    else
      card = card_for_id(params[:card_id])
      if card && @interface.available?(card)
        @interface.selected_card = card
      end
    end
    redirect_to_index
  end

  def action_to_play
    select_card
  end

  def action_to_double_play
    select_card
  end

  def from_hand_to_back_on_top
    select_card(false)
  end

  def reaction_card
    select_card
  end

  def keep_card_in_hand_or_not
    select_yes_or_no
  end

  def discard_or_put_back_on_top
    select_yes_or_no
  end

  def card_to_trash_or_keep
    @victim_state = @interface.victim_state
    card = card_for_id(params[:card_id])
    if card
      @interface.selected_card = card
    end
    redirect_to_index
  end

  def keep_or_not
    select_yes_or_no
  end

  def select_card(none_ok=true)
    @none_ok = none_ok
    if (params[:card_id] == "None")
      @interface.selected_cards = []
    else
      card = card_for_id(params[:card_id])
      if card
        @interface.selected_card = card
      end
    end
    redirect_to_index
  end

  def card_to_upgrade
    select_card
  end

  def treasure_to_upgrade
    select_card
  end

  def cards_to_keep_in_hand
    cards = cards_for_id_list(params[:card_id_list])
    status_message = nil
    if cards
      if cards.size != @interface.max
        status_message = "You must keep exactly #{@interface.max}"
      else
        @interface.selected_cards = cards
      end
    end

    redirect_to_index(status_message)
  end

  def cards_to_replace
    cards = cards_for_id_list(params[:card_id_list])
    if cards
      discard_cards = []
      @hand.each do |hand_card|
        keep = false
        cards.each do |keep_card|
          if hand_card.card_id == keep_card.card_id
            keep = true;
            break;
          end
        end
        if !keep
          discard_cards << hand_card
        end
      end
      @interface.selected_cards = discard_cards
    end

    redirect_to_index
  end

  def cards_to_trash
    status_message = nil
    cards = cards_for_id_list(params[:card_id_list])
    if cards
      discard_cards = []
      @hand.each do |hand_card|
        keep = false
        cards.each do |keep_card|
          if hand_card.card_id == keep_card.card_id
            keep = true;
            break;
          end
        end
        if !keep
          discard_cards << hand_card
        end
      end
      if discard_cards.size > @interface.max
        status_message = "You can only trash #{@interface.max}"
      else
        @interface.selected_cards = discard_cards
      end
    end
    redirect_to_index(status_message)
  end

  def trash_for_discount_or_not
    select_yes_or_no
  end

  def shuffle_or_not
    select_yes_or_no
  end

  def select_yes_or_no
    if !params[:yes_or_no].nil?
      @interface.selected_choice = yes?(params[:yes_or_no])
    end
    redirect_to_index
  end

  private
  def game_state
    @interface = DominionGameServer.rejoin_game(current_user.id)
    if @interface.nil?
      redirect_to :controller=>:lobby, :action=>:index
    else
      @interface.lock.lock
      begin
        @game_state = @interface.state.to_s.downcase
        if @game_state == "new_game"
          redirect_to :action=>"new_game"
          return
        end

        @available = @interface.get_available
        @single_available = @available && @available[0]
        @turn_state = @interface.turn_state
        @current_player_name = @turn_state.current_player_state.name
        @is_my_turn = @turn_state.my_turn?
        @other_player_states = @turn_state.other_player_states
        @player_states = @turn_state.player_states
        @hand = @turn_state.hand
        @available_standard_cards = @interface.turn_state.available_standard_cards
        @available_kingdom_cards = @interface.turn_state.available_kingdom_cards
        @played_cards = @turn_state.played_cards
        @victim_state = @interface.victim_state
        @discount = @interface.discount
        @player_id = @interface.player_id
        @am_victim = @victim_state && @player_id == @victim_state.player_id
        @victim_name = @victim_state && @victim_state.name
      ensure
        @interface.lock.unlock
      end
    end
  end

  def cards_for_id_list(card_id_list)
    logger.info "Card List #{card_id_list}"
    if card_id_list.nil?
      nil
    elsif card_id_list.blank?
      []
    else
      card_id_list.split(",").map do |card_id|
        card = card_for_id(card_id)
        if !card
          raise "Invalid card id #{card_id}"
        end
        card
      end
    end
  end

  def card_for_id(card_id)
    if card_id =~ /card_([0-9]+)/
      @interface.get_card($1.to_i)
    elsif card_id =~ /([0-9]+)/
      @interface.get_card($1.to_i)
    else
      nil
    end
  end

  def card_name(card)
    card ? card.to_s.underscore : "blank"
  end

  def yes?(string)
    string && string.downcase == "yes"
  end

  def add_player_states
    if @turn_state.game_over? && @turn_state.winners
      add_top_message("GAME OVER")
      @winning_player_ids = @turn_state.winners.map{|winner| winner.player.player_id}
    elsif !@is_my_turn
      add_top_message(@current_player_name + "'s turn")
    end

    @player_states.each_with_index do |player_state, i|
      @objects << HandImage.new(155, 8 + i*53, player_state.hand_size)
      @objects << DeckImage.new(195, 1 + i*53, player_state.deck_size)
      @objects << DiscardImage.new(235, 6 + i*53, player_state.discard_size)
      if @turn_state.game_over?
        @objects << PointsImage.new(115, 6 + i*53, player_state.score)
      end
      @objects << MessageObject.new(8, 8 + i*53, player_state.name)
      if @winning_player_ids && @winning_player_ids.include?(player_state.player_id)
        @objects << MessageObject.new(8, 24 + i*53, "WINNER!")
      end
    end
  end

  def add_top_message(msg)
    if !params[:status_message].blank?
      msg = params[:status_message] + " - " + msg
    end
    @objects << MessageObject.new(278, 265, msg)
  end

  def add_bottom_message(msg)
    if !params[:status_message].blank?
      msg = params[:status_message] + " - " + msg
    end
    @objects << MessageObject.new(278, 445, msg)
  end

  def add_available_cards
    if @game_state == "card_to_gain"
      add_available_cards_to_gain
    else
      @available_standard_cards.each_with_index do |card, index|
        @objects << CardImage.tiny_card(card, 285 + (index*77), 5)
        @objects << CoinImage.new(287 + (index*77), 96, card.cost)
        remaining_cards = @interface.turn_state.number_available(card)
        if remaining_cards < 5
          @objects << NumberImage.new(332 + (index*77), 96, remaining_cards)
        end
      end

      @available_kingdom_cards.each_with_index do |card, index|
        @objects << CardImage.tiny_card(card, 285 + (index*77), 128)
        @objects << CoinImage.new(287 + (index*77), 219, card.cost)
        remaining_cards = @interface.turn_state.number_available(card)
        if remaining_cards < 5
          @objects << NumberImage.new(332 + (index*77), 219, remaining_cards)
        end
      end
    end
  end

  def add_available_cards_to_gain
    add_top_message("Select a card to gain from above, or")
    @available_standard_cards.each_with_index do |card, index|
      if @interface.available? card
        @objects << PostableCardImage.tiny_card(card, url_for(:action=>:card_to_gain, :card_id=>card.card_id),
                                                285 + (index*77), 5)
      else
        @objects << CardImage.tiny_card(card, 285 + (index*77), 5, false)
      end
      @objects << CoinImage.new(287 + (index*77), 96, card.cost)
      remaining_cards = @interface.turn_state.number_available(card)
      if remaining_cards < 5
        @objects << NumberImage.new(332 + (index*77), 96, remaining_cards)
      end
    end

    @available_kingdom_cards.each_with_index do |card, index|
      if @interface.available? card
        @objects << PostableCardImage.tiny_card(card, url_for(:action=>:card_to_gain, :card_id=>card.card_id),
                                           285 + (index*77), 128)
      else
        @objects << CardImage.tiny_card(card, 285 + (index*77), 128, false)
      end
      @objects << CoinImage.new(287 + (index*77), 219, card.cost)
      remaining_cards = @interface.turn_state.number_available(card)
      if remaining_cards < 5
        @objects << NumberImage.new(332 + (index*77), 219, remaining_cards)
      end
    end

    @objects << PostableImage.new("none.png", url_for(:action=>:card_to_gain, :card_id=>"None"), 278, 285)
  end

  def add_question_cards
    msg = case @game_state
          when "discard_or_put_back_on_top":
            if @am_victim
              player = "your"
            else
              player = "#{@victim_name}'s"
            end
            "From top of #{player} deck: discard?"
          when "trash_for_discount_or_not":
              "Would you like to trash one of your #{@single_available} for #{@discount}?"
          when "keep_card_in_hand_or_not":
              "Would you like to keep this card in your hand?"
          when "keep_or_not": "Would you like to keep this card from #{@victim_name}?"
          when "shuffle_or_not": "Would you like to shuffle your discard into your deck?"
          when "card_to_trash_or_keep": "Select the card you would like to trash or keep:"
          else nil
          end

    if msg
      @objects << PanelObject.new(720, 260, 340, 226, 1)
      @objects << MessageObject.new(725, 265, msg, 2)
    end

    if ["keep_or_not", "shuffle_or_not", "keep_card_in_hand_or_not",
        "discard_or_put_back_on_top", "trash_for_discount_or_not"].include?(@game_state)
      @objects << PostableImage.new("yes.png", url_for(:action=>@game_state, :yes_or_no=>"Yes"), 725, 285, 2)
      @objects << PostableImage.new("no.png", url_for(:action=>@game_state, :yes_or_no=>"No"), 772, 285, 2)
      if @single_available
        @objects << CardImage.tiny_card(@single_available, 750, 315, true, false, 2)
      end

    elsif ["card_to_trash_or_keep"].include?(@game_state)
      @available.each_with_index do |card, i|
        @objects << PostableCardImage.tiny_card(card,
                                                url_for(:action=>@game_state, :card_id=>card.card_id),
                                                750 + (i * 77), 315, 2)
      end
    end
  end

  def add_hand_cards
    msg = case @game_state
          when "action_to_play": "Select an action to play, or "
          when "action_to_double_play": "Select an action to play twice, or "
          when "from_hand_to_back_on_top": "Choose a card to put back on top of your library."
          when "card_to_upgrade": "Select a card to remodel."
          when "treasure_to_upgrade": "Select a treasure to upgrade."
          when "reaction_card": "You may select a card to react with, or "
          when "cards_to_replace": "Select the cards you want to keep."
          when "cards_to_trash": "Select the cards you want to trash (highlighted are kept)."
          when "cards_to_keep_in_hand": "Select the #{@interface.max} cards you want to keep."
          else nil
          end
    if msg
      add_bottom_message(msg)
    end

    if ["action_to_play", "action_to_double_play",
        "from_hand_to_back_on_top",
        "reaction_card", "card_to_upgrade", "treasure_to_upgrade"].include?(@game_state)
      @hand.each_with_index do |card, index|
        (x, y) = hand_card_location(index, @hand.size)
        if @interface.available? card
          @objects << PostableCardImage.tiny_card(card,
                                                  url_for(:action=>@game_state, :card_id=>card.card_id),
                                                  x, y)
        else
          @objects << CardImage.tiny_card(card, x, y, false)
        end
      end
      if @game_state != "from_hand_to_back_on_top"
        @objects << PostableImage.new("none.png", url_for(:action=>@game_state, :card_id=>"None"),
                                      278, 462)
      end
    elsif ["cards_to_replace", "cards_to_trash", "cards_to_keep_in_hand"].include?(@game_state)
      if @game_state == "cards_to_trash"
        all_selected = true
        selected_ids = @hand.map{|card|card.card_id}.join(",")
      else
        all_selected = false
        selected_ids = ""
      end
      @hand.each_with_index do |card, index|
        (x, y) = hand_card_location(index, @hand.size)
        @objects << CardImage.tiny_card(card, x, y, all_selected, true)
      end
      @objects << SubmitSelectionImage.new(url_for(:action=>@game_state, :as_update=>true),
                                           selected_ids, 278, 462)
    else
      @hand.each_with_index do |card, index|
        (x, y) = hand_card_location(index, @hand.size)
        @objects << CardImage.tiny_card(card, x, y)
      end
    end
  end

  def add_played_cards
    @played_cards.each_with_index do |card, i|
      (x, y) = played_card_location(i, @played_cards.size)
      @objects << CardImage.tiny_card(card, x, y)
    end
  end

  def add_events
    @game_events.each do |event|
      event_player = event.player
      src_event_player = event.source_player
      if event_player && (!src_event_player || src_event_player.player_id != @player_id)
        player_name = event_player && event_player.name ? event_player.name : "Nobody"
        if @player_id == event_player.player_id
          player_name = "You"
        end
        msg = case event.type
              when GameStateEvent::Type::BOUGHT: "#{player_name} bought:"
              when GameStateEvent::Type::GAINED: "#{player_name} gained:"
              when GameStateEvent::Type::ADDED_TO_HAND: "#{player_name} added to their hand:"
              when GameStateEvent::Type::ADDED_TO_TOP_OF_DECK: "#{player_name} added to top of their deck:"
              when GameStateEvent::Type::DISCARDED: "#{player_name} discarded:"
              when GameStateEvent::Type::REPLACED: "#{player_name} replaced:"
              when GameStateEvent::Type::SHUFFLED: "#{player_name} shuffled"
              when GameStateEvent::Type::TRASHED: "#{player_name} trashed:"
              when GameStateEvent::Type::SET_ASIDE: "#{player_name} set aside:"
              when GameStateEvent::Type::UPGRADED: "#{player_name} upgraded:"
              when GameStateEvent::Type::STOLE: "#{src_event_player.name} stole from #{player_name.downcase}:"
              when GameStateEvent::Type::REACTED: "#{player_name} reacted with:"
              when GameStateEvent::Type::MESSAGE: "#{player_name} says:"
              else
                nil
              end
        if msg
          event_objects = []
          event_objects << PanelObject.new(720, 260, 340, 226, 3)
          event_objects << MessageObject.new(725, 265, msg, 4)
          if GameStateEvent::Type::MESSAGE == event.type
            event_objects << MessageObject.new(735, 285, event.message, 4)
          end
          event_cards = event.cards
          if event_cards
            event_cards.each_with_index do |card, i|
              (x, y) = event_card_location(i, event_cards.size)
              event_objects << CardImage.tiny_card(card, x, y, true, false, 4)
            end
          end
          @events << event_objects
        end
      end
    end
  end

  def played_card_location(index, total)
    card_width = 410.0 / total.to_f
    if card_width < 40
      card_width = 40
    elsif card_width > 77
      card_width = 77
    end
    [285 + (index * card_width), 320]
  end

  def event_card_location(index, total)
    card_width = 280.0 / total.to_f
    if card_width < 40
      card_width = 40
    elsif card_width > 77
      card_width = 77
    end
    [775 + (index * card_width).to_i, 320]
  end

  def hand_card_location(index, total)
    card_width = 750.0 / total.to_f
    if card_width < 40
      card_width = 40
    elsif card_width > 77
      card_width = 77
    end
    [285 + (index * card_width).to_i, 495]
  end

  def redirect_to_index(status_message=nil)
    if params[:as_update]
      redirect_to :action=>:update, :status_message=>status_message
    else
      redirect_to :action=>:index, :status_message=>status_message
    end
  end
end
