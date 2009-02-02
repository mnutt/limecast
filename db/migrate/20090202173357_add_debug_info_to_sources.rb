class AddDebugInfoToSources < ActiveRecord::Migration
  def self.up
    add_column :sources, :curl_info, :text
		add_column :sources, :ffmpeg_info, :text
  end

  def self.down
    remove_column :sources, :debug_info
  end
end
