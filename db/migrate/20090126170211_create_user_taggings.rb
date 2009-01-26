class CreateUserTaggings < ActiveRecord::Migration
  def self.up
    create_table :user_taggings do |t|
      t.integer :user_id
      t.integer :tagging_id
    end
  end

  def self.down
    drop_table :user_taggings
  end
end
