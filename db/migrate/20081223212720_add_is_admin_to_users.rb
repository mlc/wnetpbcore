class AddIsAdminToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_admin, :boolean, :null => false, :default => false
    admin = User.find_by_login('admin')
    admin.update_attribute(:is_admin, true) unless admin.nil?
  end

  def self.down
    remove_column :users, :is_admin
  end
end
