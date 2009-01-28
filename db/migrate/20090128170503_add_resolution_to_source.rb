class AddResolutionToSource < ActiveRecord::Migration
  def self.up
    add_column :sources, :height, :integer
    add_column :sources, :width, :integer
  end

  def self.down
    remove_column :sources, :width
    remove_column :sources, :height
  end
end
