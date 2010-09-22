class IndexVersionsOnAssetId < ActiveRecord::Migration
  def self.up
    add_index :versions, :asset_id
  end

  def self.down
    remove_index :versions, :asset_id
  end
end
