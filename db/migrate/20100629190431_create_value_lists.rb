class CreateValueLists < ActiveRecord::Migration
  def self.up
    create_table :value_lists do |t|
      t.string :table_name, :null => false
      t.string :fixed_field_name
      t.integer :fixed_field_value
    end
    add_index :value_lists, :table_name

    create_table :values do |t|
      t.integer :value_list_id, :null => false
      t.string :value, :null => false
    end
    add_index :values, :value_list_id
  end

  def self.down
    drop_table :values
    drop_table :value_lists
  end
end
