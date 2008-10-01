class ChangePodcastEmailToOwnerEmail < ActiveRecord::Migration
  def self.up
    rename_column :podcasts, :email, :owner_email
  end

  def self.down
    rename_column :podcasts, :owner_email, :email
  end
end
