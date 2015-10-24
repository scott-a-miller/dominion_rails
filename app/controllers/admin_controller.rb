require "game_server"

class AdminController < ApplicationController
  def index
    @games = DominionGameServer.games
  end

  def stop_game
    if params[:id]
      game = DominionGameServer.game_by_id(params[:id].to_i)
      if game
        game.stop_game
      end
    end
    redirect_to :action=>:index
  end

  def remove_game
    if params[:id]
      game = DominionGameServer.game_by_id(params[:id].to_i)
      if game
        if !game.stopped
          game.stop_game
        end
        DominionGameServer.remove_game(game)
      end
    end
    redirect_to :action=>:index
  end
end
