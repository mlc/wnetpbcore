class AddIpBlocks < ActiveRecord::Migration
  def self.up
    create_table :ip_blocks do |t|
      t.string :name, :null => false
      t.text :ranges
    end
    add_index :ip_blocks, :name, :unique => true

    add_column :users, :ip_block_id, :int, :null => true, :default => nil
  end

  def self.down
    remove_column :users, :ip_block_id
    drop_table :ip_blocks
  end
end
