class AddXmlTextForDebugging < ActiveRecord::Migration
  def self.up
    add_column :feeds, :xml, :text, :limit => 500.kilobytes
    add_column :sources, :xml, :text
  end

  def self.down
    remove_column :feeds, :xml
    remove_column :sources, :xml
  end
end
