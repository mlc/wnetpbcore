class AddIndexToEssenceTrackIdentifiers < ActiveRecord::Migration
  def self.up
    add_index :essence_track_identifiers, :essence_track_id
  end

  def self.down
    remove_index :essence_track_identifiers, :essence_track_id
  end
end