require 'dominion.jar'

module DominionGameServer
  include Java

  BasicConfigurations = com.brokenmodel.dominion.BasicConfigurations
  RandomConfiguration = com.brokenmodel.dominion.RandomConfiguration

  def self.instance
    com.brokenmodel.dominion.GameServer.instance
  end

  def self.create_easy_single_player_game(player_id, name)
    self.instance.create_single_player_game(3, player_id, name,
                                            RandomConfiguration.new,
                                            true)
  end

  def self.create_difficult_single_player_game(player_id, name)
    self.instance.create_single_player_game(3, player_id, name,
                                            RandomConfiguration.new,
                                            false)
  end

  def self.rejoin_game(player_id)
    self.instance.get_player_in_game(player_id)
  end

  def self.join_new_game(player_id, name)
    self.instance.join_new_game(player_id, name)
  end

  def self.rejoin_game_or_create(player_id, name)
    self.instance.rejoin_game_or_create(player_id, name)
  end

  def self.exit_game(player_id)
    self.instance.exit_game(player_id)
  end

  def self.remove_game(game)
    self.instance.remove_game(game.game_id)
  end

  def self.games
    self.instance.games
  end

  def self.game_by_id(id)
    self.instance.get_game_by_id(id)
  end
end
