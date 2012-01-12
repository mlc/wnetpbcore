class AddIndexForAnnotations < ActiveRecord::Migration
  def self.up
    add_index :annotations, [:container_id, :container_type]
  end

  def self.down
    remove_index :annotations, [:container_id, :container_type]
  end
end