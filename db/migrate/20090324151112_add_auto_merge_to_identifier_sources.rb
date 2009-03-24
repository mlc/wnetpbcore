class AddAutoMergeToIdentifierSources < ActiveRecord::Migration
  def self.up
    add_column :identifier_sources, :auto_merge, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :identifier_sources, :auto_merge
  end
end
