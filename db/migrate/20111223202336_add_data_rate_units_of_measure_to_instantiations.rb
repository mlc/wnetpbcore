class AddDataRateUnitsOfMeasureToInstantiations < ActiveRecord::Migration
  def self.up
    add_column :instantiations, :format_data_rate_units_of_measure, :string
  end

  def self.down
    remove_column :instantiations, :format_data_rate_units_of_measure
  end
end