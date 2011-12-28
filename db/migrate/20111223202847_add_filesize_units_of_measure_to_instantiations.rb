class AddFilesizeUnitsOfMeasureToInstantiations < ActiveRecord::Migration
  def self.up
    add_column :instantiations, :format_file_size_units_of_measure, :string
  end

  def self.down
    remove_column :instantiations, :format_file_size_units_of_measure
  end
end