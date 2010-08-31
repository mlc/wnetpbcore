class MoreFlexibleRoles < ActiveRecord::Migration
  def self.up
    add_column :users, :role, :string, :default => 'user', :null => false
    User.all.each do |user|
      user.update_attribute(:role, user.is_admin? ? 'admin' : 'user')
    end
    remove_column :users, :is_admin
  end

  def self.down
    add_column :users, :is_admin, :boolean, :null => false, :default => false
    User.all.each do |user|
      user.update_attribute(:is_admin, user.role == 'admin')
    end
    remove_column :users, :role
  end
end
