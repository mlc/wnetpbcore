class AddForgottenIndexOnCoverages < ActiveRecord::Migration
  def self.up
    add_index :coverages, :asset_id
  end

  def self.down
    remove_index :coverages, :asset_id
  end
end
