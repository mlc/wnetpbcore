class RenameFormatMediaTypeToInstantiationMediaType < ActiveRecord::Migration
  def self.up
    rename_column :instantiations, :format_media_type_id, :instantiation_media_type_id
    rename_table :format_media_types, :instantiation_media_types
  end

  def self.down
    rename_table :instantiation_media_types, :format_media_types
    rename_column :instantiations, :instantiation_media_type_id, :format_media_type_id
  end
end