class AddDeltaIndexColumn < ActiveRecord::Migration
  def self.up
    add_column :assets, :delta, :boolean, :null => false
  end

  def self.down
    remove_column :assets, :delta
  end
end
