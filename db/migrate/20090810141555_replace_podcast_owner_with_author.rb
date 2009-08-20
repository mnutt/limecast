class Author < ActiveRecord::Base
  # JIC
  attr_accessor :clean_url
  protected
  def set_name_and_clean_url
    self.name = email.to_s.dup if name.blank?
    self.name = name.split(/@/).first
    self.name = name.increment(" (%s)", 2) while Author.exists?(["name = ? AND id != ?", name, id.to_i])
  end
end

class ReplacePodcastOwnerWithAuthor < ActiveRecord::Migration
  def self.up
    remove_column :podcasts, :owner_id
    rename_column :podcasts, :owner_name, :author_name
    rename_column :podcasts, :owner_email, :author_email

    create_table :authors, :force => true do |t|
      t.string :name
      t.string :email
      t.timestamps
    end

    add_index :authors, :name
    add_index :authors, :email
    
    Podcast.find_each do |p|
      a = Author.find_or_initialize_by_email(p.author_email)
      a.name = p.author_name unless p.author_name.blank?
      a.save!
    end
    add_index :podcasts, :author_email

    User.destroy_all(:state => "passive")
    add_column :users, :confirmed, :boolean, :default => false
    User.find_each { |u| u.update_attribute(:confirmed, (u.state == 'confirmed')) }
    remove_column :users, :state
  end

  def self.down
    add_column :users, :state, :string
    remove_column :users, :confirmed
    
    remove_index :authors, :email
    remove_index :authors, :name

    drop_table :authors

    rename_column :podcasts, :author_name, :owner_name
    rename_column :podcasts, :author_email, :owner_email
    add_column :podcasts, :owner_id, :integer
  end
end
