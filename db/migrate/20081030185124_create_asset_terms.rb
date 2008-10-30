class CreateAssetTerms < ActiveRecord::Migration
  def self.up
    create_table :asset_terms do |t|
      t.integer :asset_id, :null => false
      t.text :identifier
      t.text :title
      t.text :subject
      t.text :description
      t.text :genre
      t.text :relation
      t.text :coverage
      t.text :audience_level
      t.text :audience_rating
      t.text :creator
      t.text :contributor
      t.text :publisher
      t.text :rights
      t.text :extension
      t.text :location
      t.text :annotation
      t.text :date
      t.timestamps
      t.boolean :delta, :null => false
    end
    remove_column :assets, :delta
    begin
      ThinkingSphinx.updates_enabled = false
      Asset.all.each do |asset|
        asset.update_asset_terms
        asset.asset_terms.save
      end
    ensure
      ThinkingSphinx.updates_enabled = true
      puts "AssetTerms created. You need to reindex."
    end
    add_index :asset_terms, :asset_id, :unique => true
  end

  def self.down
    drop_table :asset_terms
    add_column :assets, :delta, :boolean, :null => false
  end
end
