class AddInstantiationStandard < ActiveRecord::Migration
  def self.up
    add_column :instantiations, :standard, :text
    add_column :instantiations, :standard_source, :text
    add_column :instantiations, :standard_ref, :text
  end

  def self.down
    remove_column :instantiations, :standard_ref
    remove_column :instantiations, :standard_source
    remove_column :instantiations, :standard
  end
end