class AddLanguageToPodcast < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :language, :string
  end

  def self.down
    remove_column :podcasts, :language
  end
end
