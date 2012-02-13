class AttachmentUploaderForAsset < ActiveRecord::Migration
  def self.up
    add_column :assets, :attachment, :string
  end

  def self.down
    remove_column :assets, :attachment
  end
end