class AddAutoMergeToFormatIdentifierSources < ActiveRecord::Migration
  def self.up
    add_column :format_identifier_sources, :auto_merge, :boolean, :default => false
  end

  def self.down
    remove_column :format_identifier_sources, :auto_merge
  end
end