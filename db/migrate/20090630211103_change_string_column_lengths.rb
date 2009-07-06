class ChangeStringColumnLengths < ActiveRecord::Migration
  def self.up
    change_column :podcasts, :subtitle, :text, :limit => 2048
    change_column :podcasts, :description, :text, :limit => 2048
    change_column :episodes, :subtitle, :text, :limit => 2048
  end

  def self.down
    change_column :podcasts, :subtitle, :string
    change_column :podcasts, :description, :string
    change_column :episodes, :subtitle, :string
  end
end
