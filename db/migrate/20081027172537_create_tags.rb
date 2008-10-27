class CreateTags < ActiveRecord::Migration
  def self.up
    drop_table :tags
    remove_column :taggings, 'user_id'

    create_table :tags do |t|
      t.string  'name'
      t.boolean 'badge'
      t.boolean 'blacklisted'

      t.integer 'map_to_id'
    end
  end

  def self.down
    drop_table :tags
  end
end
