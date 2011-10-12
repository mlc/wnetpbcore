class RenameFormatColorToInstantiationColor < ActiveRecord::Migration
  def self.up
    rename_column :instantiations, :format_color_id, :instantiation_color_id
    rename_table :format_colors, :instantiation_colors
  end

  def self.down
    rename_table :instantiation_colors, :format_colors
    rename_column :instantiations, :instantiation_color_id, :format_color_id
  end
end
