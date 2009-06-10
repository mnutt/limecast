class AddCreatedAtToSource < ActiveRecord::Migration
  def self.up
    add_column :sources, :created_at, :datetime
  end

  def self.down
    remove_column :sources, :created_at
  end
end
