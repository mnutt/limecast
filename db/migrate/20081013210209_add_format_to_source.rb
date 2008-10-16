class AddFormatToSource < ActiveRecord::Migration
  def self.up
    add_column :sources, :format, :string
  end

  def self.down
    remove_column :sources, :format
  end
end
