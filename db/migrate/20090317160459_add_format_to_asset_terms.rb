class AddFormatToAssetTerms < ActiveRecord::Migration
  def self.up
    add_column :asset_terms, :format, :text
    AssetTerms.regenerate_all
  end

  def self.down
    remove_column :asset_terms, :format
  end
end
