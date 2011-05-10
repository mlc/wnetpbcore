class AddAssetDates < ActiveRecord::Migration
  def self.up
    # new table for asset_dates
    create_table "asset_dates", :id => false, :force => true do |t|
      t.integer  "asset_id"
      t.integer  "asset_date_type_id"
      t.datetime "asset_date"
      t.integer  "creator_id"
      t.integer  "updater_id"
      t.boolean  "visible", :default => false, :null => false
      t.timestamps
    end

    # new table for asset_date_types
    create_table "asset_date_types", :id => false, :force => true do |t|
      t.string  "name"
      t.boolean "visible", :default => false, :null => false
    end
    
    # via http://metadataregistry.org/concept/list/vocabulary_id/162.html
    # Note that I excluded "date time stamp" as a dateType because it seems to dupe the record timestamp.
    # I'm not sure if that's the right thing to do. There are problably also other types needed here.
    %w(availableEnd availableStart broadcast content created issued portrayed published revised).each do |dt|
      AssetDateType.create!(:name => dt, :visible=>true)
    end

    # index for asset_date_types 
    add_index "asset_dates", "asset_id"
  end

  def self.down
    drop_table "asset_dates"
    drop_table "asset_date_types"
  end
end
