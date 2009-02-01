class AddXmlTextForDebugging < ActiveRecord::Migration
  def self.up
    add_column :feeds, :xml, :text
    add_column :sources, :xml, :text
  end

  def self.down
    remove_column :feeds, :xml
    remove_column :sources, :xml
  end
end
