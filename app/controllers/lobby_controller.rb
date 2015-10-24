require "game_server"

class LobbyController < ApplicationController
  before_filter :login_required

  def index
    if DominionGameServer.rejoin_game(current_user.id)
      redirect_to :controller=>:games, :action=>:index
      return
    end

    @min_human_count = DominionGameServer.instance.get_min_human_count(current_user.id)
    @max_human_count = DominionGameServer.instance.get_max_human_count(current_user.id)

    @number_playing = DominionGameServer.instance.playing_count
    @number_waiting = DominionGameServer.instance.waiting_count

    if @min_human_count.nil? || @min_human_count == 0
      @wait_for_humans = current_user.easy? ? "easy_ai" : "difficult_ai"
    elsif @max_human_count.nil? || @max_human_count > 2
      @wait_for_humans = @min_human_count - 1
    else
      @wait_for_humans = "two_player_only"
    end
  end

  def check_status
    if DominionGameServer.rejoin_game(current_user.id)
      render :text=>"\"Ready\""
    else
      @number_playing = DominionGameServer.instance.playing_count
      @number_waiting = DominionGameServer.instance.waiting_count
      render :text=>"{ waiting: \"#{@number_waiting}\", playing: \"#{@number_playing}\" }"
    end
  end

  def update
    if params[:wait_for_humans]
      if params[:wait_for_humans] == "easy_ai"
        current_user.easy = true
        DominionGameServer.create_easy_single_player_game(current_user.id, current_user.login)
      elsif params[:wait_for_humans] == "difficult_ai"
        current_user.easy = false
        DominionGameServer.create_difficult_single_player_game(current_user.id, current_user.login)
      elsif params[:wait_for_humans] == "two_player_only"
        DominionGameServer.instance.create_or_rejoin_multi_player_game(current_user.id,
                                                                       current_user.login,
                                                                       2, 2)
      else
        min_human_count = params[:wait_for_humans].to_i + 1
        DominionGameServer.instance.create_or_rejoin_multi_player_game(current_user.id,
                                                                       current_user.login,
                                                                       min_human_count, 4)
      end
    end

    current_user.save!

    redirect_to :action=>:index
  end
end
