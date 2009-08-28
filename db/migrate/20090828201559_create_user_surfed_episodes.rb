class CreateUserSurfedEpisodes < ActiveRecord::Migration
  def self.up
    create_table :user_surfed_episodes, :force => true do |t|
      t.integer :episode_id
      t.integer :user_id
      t.datetime :viewed_at
    end
  end

  def self.down
    drop_table :user_surfed_episodes
  end
end
