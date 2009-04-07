class AddSizeInXmlAndOnDiskToSource < ActiveRecord::Migration
  def self.up
    add_column :sources, :size_from_xml, :integer
    add_column :sources, :size_from_disk, :integer

    execute <<-SQL
      UPDATE sources SET size_from_disk = size;
    SQL

    remove_column :sources, :size
  end

  def self.down
    add_column :sources, :size, :integer

    remove_column :sources, :size_from_disk
    remove_column :sources, :size_from_xml
  end
end
