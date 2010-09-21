class CreateValueLists < ActiveRecord::Migration
  def self.up
    create_table :value_lists do |t|
      t.string :category, :null => false
      t.string :value, :null => false
    end
    add_index :value_lists, [:category, :value], :unique => true

    create_table :values do |t|
      t.integer :value_list_id, :null => false
      t.string :value, :null => false
    end
    add_index :values, [:value_list_id, :value], :unique => true
  end

  def self.down
    drop_table :values
    drop_table :value_lists
  end
end
