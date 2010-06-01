class EssenceTrackIdentifierSourceOptional < ActiveRecord::Migration
  def self.up
    change_column(:essence_tracks, :essence_track_type_id, :integer, :null => true)
    change_column(:essence_tracks, :essence_track_identifier_source_id, :integer, :null => true)
  end

  def self.down
    change_column(:essence_tracks, :essence_track_type_id, :integer, :null => false)
    change_column(:essence_tracks, :essence_track_identifier_source_id, :integer, :null => false)
  end
end
