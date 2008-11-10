class CreateFavorites < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.integer :user_id
      t.integer :episode_id
      t.timestamps
    end

    add_index :favorites, :user_id
    add_index :favorites, :episode_id
  end

  def self.down
    drop_table :favorites
  end
end
