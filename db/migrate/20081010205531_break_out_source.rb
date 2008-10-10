class BreakOutSource < ActiveRecord::Migration
  def self.up
    create_table "sources" do |t|
      t.string "url"
      t.string "type"
      t.string "guid"
      t.integer "size"

      t.integer :episode_id
    end

    remove_column "episodes", :enclosure_url
    remove_column "episodes", :enclosure_type
    remove_column "episodes", :enclosure_size
    remove_column "episodes", :guid
  end

  def self.down
    add_column "episodes", :enclosure_url, :string
    add_column "episodes", :enclosure_type, :string
    add_column "episodes", :enclosure_size, :integer
    add_column "episodes", :guid, :string

    drop_table "sources"
  end
end
