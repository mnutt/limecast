class SwapTitleAndCustomTitleForPodcasts < ActiveRecord::Migration
  def self.up
    rename_column :podcasts, :title, :original_title
    rename_column :podcasts, :custom_title, :title
  end

  def self.down
    rename_column :podcasts, :title, :custom_title
    rename_column :podcasts, :original_title, :title
  end
end
