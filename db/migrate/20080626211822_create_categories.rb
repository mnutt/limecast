class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.integer :position

      t.timestamps
    end
    add_column :podcasts, :category_id, :integer
  end

  def self.down
    drop_table :categories
    remove_column :podcasts, :category_id
  end
end
