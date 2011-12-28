class AddEssenceTrackSamplingRateUnitsOfMeasured < ActiveRecord::Migration
  def self.up
    add_column :essence_tracks, :essence_track_sampling_rate_units_of_measure, :string
  end

  def self.down
    remove_column :essence_tracks, :essence_track_sampling_rate_units_of_measure
  end
end