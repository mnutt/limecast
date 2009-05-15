class AddErrorFieldToPodcast < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :error, :string
  end

  def self.down
    remove_column :podcasts, :error
  end
end
