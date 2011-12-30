class CreateInstantiationRightsSummaries < ActiveRecord::Migration
  def self.up
    create_table :instantiation_rights_summaries do |t|
      t.integer :instantiation_id
      t.text :rights_summary
      t.text :source
      t.text :ref
      t.integer :creator_id
      t.integer :updater_id

      t.timestamps
    end
  end

  def self.down
    drop_table :instantiation_rights_summaries
  end
end
