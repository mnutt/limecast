class AddLoggedInAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :logged_in_at, :datetime
    User.all.each do |user|
      user.update_attribute(:logged_in_at, Time.now)
    end
  end

  def self.down
    remove_column :users, :logged_in_at
  end
end
