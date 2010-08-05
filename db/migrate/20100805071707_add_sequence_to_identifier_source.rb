class AddSequenceToIdentifierSource < ActiveRecord::Migration
  def self.up
    add_column :identifier_sources, :sequence, :integer, :null => true
  end

  def self.down
    remove_column :identifier_sources, :sequence
  end
end
