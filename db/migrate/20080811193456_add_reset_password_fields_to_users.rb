class AddResetPasswordFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :reset_password_code, :string
    add_column :users, :reset_password_sent_at, :datetime
  end

  def self.down
    remove_column :users, :reset_password_sent_at
    remove_column :users, :reset_password_code
  end
end
