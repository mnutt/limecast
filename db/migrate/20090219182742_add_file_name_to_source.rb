class AddFileNameToSource < ActiveRecord::Migration
  def self.up
    add_column :sources, :file_name, :string
  end

  def self.down
    remove_column :sources, :file_name
  end
end
