class AddSourceToCreatorAndRemoveSomeUnusedAttributes < ActiveRecord::Migration
  TABLES = [:creators, :contributors, :publishers]
  def self.up
    TABLES.each do |table|
      add_column    table, :source, :text
      remove_column table, :role_source
      remove_column table, :role_ref
      remove_column table, :role_version
      remove_column table, :role_annotation
    end
  end

  def self.down
    TABLES.each do |table|
      add_column    table, :role_annotation, :text
      add_column    table, :role_version, :text
      add_column    table, :role_ref, :text
      add_column    table, :role_source, :text
      remove_column table, :source
    end
  end
end
