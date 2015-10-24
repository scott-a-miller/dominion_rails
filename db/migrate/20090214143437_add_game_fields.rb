class AddGameFields < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.integer :preferred_human_count
      t.integer :preferred_player_count
      t.integer :wait_time
      t.boolean :easy
      t.string :state, :limit=>20
      t.timestamp :last_update
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :preferred_human_count
      t.remove :preferred_player_count
      t.remove :wait_time
      t.remove :easy
      t.remove :state
      t.remove :last_update
    end
  end
end
