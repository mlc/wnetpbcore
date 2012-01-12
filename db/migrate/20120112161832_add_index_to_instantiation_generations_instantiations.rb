class AddIndexToInstantiationGenerationsInstantiations < ActiveRecord::Migration
  def self.up
    add_index :instantiation_generations_instantiations, [:instantiation_id, :instantiation_generation_id]
  end

  def self.down
    remove_index :instantiation_generations_instantiations, [:instantiation_id, :instantiation_generation_id]
  end
end