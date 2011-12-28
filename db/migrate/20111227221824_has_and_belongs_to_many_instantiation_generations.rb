class HasAndBelongsToManyInstantiationGenerations < ActiveRecord::Migration
  def self.up
    create_table :instantiation_generations_instantiations, :force => true, :id => false do |t|
      t.integer :instantiation_id
      t.integer :instantiation_generation_id
    end
    
    Instantiation.find_in_batches do |instantiation_batch|
      instantiation_batch.each do |instantiation|
        instantiation.instantiation_generation_ids = [instantiation.instantiation_generation_id]
      end
    end
    remove_column :instantiations, :instantiation_generation_id
  end

  def self.down
    add_column :instantiations, :instantiation_generation_id, :integer
    drop_table :instantiation_generations_instantiations
  end
end
