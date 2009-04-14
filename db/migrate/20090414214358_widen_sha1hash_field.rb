class WidenSha1hashField < ActiveRecord::Migration
  def self.up
    remove_column :sources, :sha1hash
    add_column :sources, :sha1hash, :string, :limit => 40
  end

  def self.down
  end
end
