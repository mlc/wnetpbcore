class AddShowInIndexToIdentifierSources < ActiveRecord::Migration
  def self.up
    add_column :identifier_sources, :show_in_index, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :identifier_sources, :show_in_index
  end
end
