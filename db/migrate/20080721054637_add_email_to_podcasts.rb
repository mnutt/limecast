class AddEmailToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :email, :string
  end

  def self.down
    remove_column :podcasts, :email
  end
end
