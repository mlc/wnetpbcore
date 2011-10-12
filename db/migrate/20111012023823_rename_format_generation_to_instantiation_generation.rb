class RenameFormatGenerationToInstantiationGeneration < ActiveRecord::Migration
  def self.up
    rename_column :instantiations, :format_generation_id, :instantiation_generation_id
    rename_table :format_generations, :instantiation_generations
  end

  def self.down
    rename_table :instantiation_generations, :format_generations
    rename_column :instantiations, :instantiation_generation_id, :format_generation_id
  end
end
