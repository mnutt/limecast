class CopyOverTitleToCustomTitle < ActiveRecord::Migration
  def self.up
    select_all("SELECT * FROM podcasts").each do |podcast|
      update("UPDATE podcasts SET custom_title = #{quote(podcast['title'])} WHERE id = #{podcast['id']}")
    end
  end

  def self.down
  end
end
