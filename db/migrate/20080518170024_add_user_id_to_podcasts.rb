class AddUserIdToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :user_id, :integer
  end

  def self.down
    remove_column :podcasts, :user_id
  end
end
