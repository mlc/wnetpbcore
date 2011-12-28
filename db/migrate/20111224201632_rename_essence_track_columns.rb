class RenameEssenceTrackColumns < ActiveRecord::Migration
  def self.up
    rename_column :essence_tracks, :essence_track_identifier, :identifier
    rename_column :essence_tracks, :essence_track_standard, :standard
    rename_column :essence_tracks, :essence_track_encoding, :encoding
    rename_column :essence_tracks, :essence_track_data_rate, :data_rate
    rename_column :essence_tracks, :essence_track_time_start, :time_start
    rename_column :essence_tracks, :essence_track_duration, :duration
    rename_column :essence_tracks, :essence_track_bit_depth, :bit_depth
    rename_column :essence_tracks, :essence_track_sampling_rate, :sampling_rate
    rename_column :essence_tracks, :essence_track_frame_size, :frame_size
    rename_column :essence_tracks, :essence_track_aspect_ratio, :aspect_ratio
    rename_column :essence_tracks, :essence_track_frame_rate, :frame_rate
    rename_column :essence_tracks, :essence_track_language, :language
    rename_column :essence_tracks, :essence_track_annotation, :annotation
    rename_column :essence_tracks, :essence_track_sampling_rate_units_of_measure, :sampling_rate_units_of_measure
  end

  def self.down
    rename_column :essence_tracks, :sampling_rate_units_of_measure, :essence_track_sampling_rate_units_of_measure
    rename_column :essence_tracks, :annotation, :essence_track_annotation
    rename_column :essence_tracks, :language, :essence_track_language
    rename_column :essence_tracks, :frame_rate, :essence_track_frame_rate
    rename_column :essence_tracks, :aspect_ratio, :essence_track_aspect_ratio
    rename_column :essence_tracks, :frame_size, :essence_track_frame_size
    rename_column :essence_tracks, :sampling_rate, :essence_track_sampling_rate
    rename_column :essence_tracks, :bit_depth, :essence_track_bit_depth
    rename_column :essence_tracks, :duration, :essence_track_duration
    rename_column :essence_tracks, :time_start, :essence_track_time_start
    rename_column :essence_tracks, :data_rate, :essence_track_data_rate
    rename_column :essence_tracks, :encoding, :essence_track_encoding
    rename_column :essence_tracks, :standard, :essence_track_standard
    rename_column :essence_tracks, :identifier, :essence_track_identifier
  end
end