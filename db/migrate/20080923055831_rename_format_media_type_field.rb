class RenameFormatMediaTypeField < ActiveRecord::Migration
  def self.up
    rename_column :instantiations, :format_media_type, :format_media_type_id
  end

  def self.down
    rename_column :instantiations, :format_media_type_id, :format_media_type
  end
end
