class CreateInstantiationRelations < ActiveRecord::Migration
  def self.up
    create_table :instantiation_relations do |t|
      t.integer :instantiation_id
      t.string :instantiation_relation_identifier
      t.integer :relation_type_id
      t.integer :creator_id
      t.integer :updater_id

      t.timestamps
    end
  end

  def self.down
    drop_table :instantiation_relations
  end
end
