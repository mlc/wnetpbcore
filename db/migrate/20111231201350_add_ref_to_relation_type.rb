class AddRefToRelationType < ActiveRecord::Migration
  def self.up
    add_column :relation_types, :ref, :text
  end

  def self.down
    remove_column :relation_types, :ref
  end
end