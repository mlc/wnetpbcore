class PluralizeAnnotationsTable < ActiveRecord::Migration
  def self.up
    rename_table :annotation, :annotations
  end

  def self.down
    rename_table :annotations, :annotation
  end
end
