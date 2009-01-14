class MakeSourceSizeABigInteger < ActiveRecord::Migration
  def self.up
    add_column :sources, :tmp, :bigint

    execute <<-SQL
      UPDATE sources
      SET    sources.tmp = sources.size
    SQL

    remove_column :sources, :size
    rename_column :sources, :tmp, :size
  end

  def self.down
    add_column :sources, :tmp, :int

    execute <<-SQL
      UPDATE sources
      SET    sources.tmp = sources.size
    SQL

    remove_column :sources, :size
    rename_column :sources, :tmp, :size
  end
end
