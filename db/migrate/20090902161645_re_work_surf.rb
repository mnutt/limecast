class ReWorkSurf < ActiveRecord::Migration
  def self.up
    drop_table :user_surfed_episodes        

    create_table :surf_episodes, :force => true do |t|
      t.integer :episode_id
      t.integer :order
    end
  end

  def self.down
    create_table :user_surfed_episodes, :force => true do |t|
      t.integer :episode_id
      t.integer :user_id
      t.datetime :viewed_at
    end

    drop_table :surf_episodes
  end
end
