class AddSomeUsefulIndices < ActiveRecord::Migration
  def self.up
    add_index :sources, :preview_file_size
    add_index :sources, :screenshot_file_size
  end

  def self.down
    remove_index :sources, :preview_file_size
    remove_index :sources, :screenshot_file_size
  end
end

