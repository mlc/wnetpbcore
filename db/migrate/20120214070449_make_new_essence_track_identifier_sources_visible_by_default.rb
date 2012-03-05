class MakeNewEssenceTrackIdentifierSourcesVisibleByDefault < ActiveRecord::Migration
  def self.up
    change_column_default :essence_track_identifier_sources, :visible, 1
  end

  def self.down
    change_column_default :essence_track_identifier_sources, :visible, 0
  end
end