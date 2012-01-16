class InstantiationDigitizedFlag < ActiveRecord::Migration
  def self.up
    add_column :instantiations, :digitized, :boolean, :default => false
  end

  def self.down
    remove_column :instantiations, :digitized
  end
end