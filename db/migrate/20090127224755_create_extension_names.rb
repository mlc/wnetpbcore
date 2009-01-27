class CreateExtensionNames < ActiveRecord::Migration
  def self.up
    create_table :extension_names do |t|
      t.string :extension_key
      t.string :extension_authority
      t.text :description
      t.boolean :visible, :null => false, :default => false

      t.timestamps
    end
    add_index :extension_names, [:extension_authority, :extension_key], :unique => true

    created = {}
    Extension.all.each do |ext|
      k = [ext.extension_authority_used, ext.extension_key]
      unless created.has_key?(k)
        ExtensionName.create(:extension_key => ext.extension_key, :extension_authority => ext.extension_authority_used, :visible => true)
        created[k] = true
      end
    end
  end

  def self.down
    drop_table :extension_names
  end
end
