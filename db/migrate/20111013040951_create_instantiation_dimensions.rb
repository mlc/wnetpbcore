class CreateInstantiationDimensions < ActiveRecord::Migration
  def self.up
    create_table :instantiation_dimensions do |t|
      t.integer :instantiation_id
      t.string :dimension
      t.string :units_of_measure
      t.text :annotation

      t.timestamps
    end
  end

  def self.down
    drop_table :instantiation_dimensions
  end
end
