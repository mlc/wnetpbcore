class MoveIdentifierRefToIdentifierSourceModel < ActiveRecord::Migration
  def self.up
    add_column :identifier_sources, :ref, :text
    remove_column :identifiers, :ref
  end

  def self.down
    add_column :identifiers, :ref, :text
    remove_column :identifier_sources, :ref
  end
end
