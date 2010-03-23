class AddUuidToAsset < ActiveRecord::Migration
  def self.up
    add_column :assets, :uuid, :string, :limit => 36, :null => false
    if Asset.count > 0
      Asset.update_all('uuid = UUID()')
    end
    add_index :assets, :uuid, :unique => true
  end

  def self.down
    remove_column :assets, :uuid
  end
end
