class AddUuidToInstantiation < ActiveRecord::Migration
  def self.up
    add_column :instantiations, :uuid, :string, :limit => 36, :null => false
    if Instantiation.count > 0
      Instantiation.update_all("uuid = UUID()")
    end
    add_index :instantiations, :uuid, :unique => true
  end

  def self.down
    remove_column :assets, :uuid
  end
end
