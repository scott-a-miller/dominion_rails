class MoreLobbyFields < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.timestamp :started_waiting
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :started_waiting
    end
  end
end
