class AddProtectedToPodcast < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :protected, :boolean, :default => 0
  end

  def self.down
    remove_column :podcasts, :protected
  end
end
