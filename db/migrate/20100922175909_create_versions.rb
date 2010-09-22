class CreateVersions < ActiveRecord::Migration
  def self.up
    create_table :versions do |t|
      t.references :asset, :null => false
      t.text :body
      t.integer :creator_id
      t.timestamps
    end
  end

  def self.down
    drop_table :versions
  end
end
