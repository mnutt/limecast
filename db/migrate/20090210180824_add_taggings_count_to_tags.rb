class AddTaggingsCountToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :taggings_count, :integer
    
    Tag.all.each do |tag|
      tag.update_attribute :taggings_count, tag.taggings.count
    end
  end

  def self.down
    remove_column
  end
end
