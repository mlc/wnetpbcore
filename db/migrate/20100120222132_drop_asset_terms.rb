class DropAssetTerms < ActiveRecord::Migration
  def self.up
    drop_table :asset_terms
  end

  def self.down
    create_table "asset_terms" do |t|
      t.integer  "asset_id", :null => false
      t.text     "identifier"
      t.text     "title"
      t.text     "subject"
      t.text     "description"
      t.text     "genre"
      t.text     "relation"
      t.text     "coverage"
      t.text     "audience_level"
      t.text     "audience_rating"
      t.text     "creator"
      t.text     "contributor"
      t.text     "publisher"
      t.text     "rights"
      t.text     "extension"
      t.text     "location"
      t.text     "annotation"
      t.text     "date"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "delta", :null => false
      t.text     "format"
    end

    puts "** Hey. asset_terms has been recreated, but probably you want to fill it up."
  end
end
