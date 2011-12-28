class AddEssenceTrackPlaybackSpeed < ActiveRecord::Migration
  def self.up
    add_column :essence_tracks, :playback_speed, :string
    add_column :essence_tracks, :playback_speed_units_of_measure, :string
  end

  def self.down
    remove_column :essence_tracks, :playback_speed_units_of_measure
    remove_column :essence_tracks, :playback_speed
  end
end