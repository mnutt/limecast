class RemoveTaggableFromTagging < ActiveRecord::Migration
  def self.up
    add_column :taggings, :podcast_id, :integer

    ActiveRecord::Base.connection.execute <<-SQL
      UPDATE taggings SET podcast_id = taggable_id
    SQL

    remove_column :taggings, :taggable_id
    remove_column :taggings, :taggable_type
  end

  def self.down
    add_column :taggings, :taggable_id,   :integer
    add_column :taggings, :taggable_type, :string

    ActiveRecord::Base.connection.execute <<-SQL
      UPDATE taggings SET taggable_id = podcast_id, taggable_type = "Podcast"
    SQL

    remove_column :taggings, :podcast_id
  end
end
