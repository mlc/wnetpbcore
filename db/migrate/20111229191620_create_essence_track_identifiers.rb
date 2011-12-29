class CreateEssenceTrackIdentifiers < ActiveRecord::Migration
  def self.up
    create_table :essence_track_identifiers do |t|
      t.integer :essence_track_id
      t.text :identifier
      t.integer :essence_track_identifier_source_id

      t.timestamps
    end
    
    EssenceTrack.find_in_batches do |batch|
      batch.each do |essence_track|
        if essence_track.identifier.present?
          essence_track_identifier = EssenceTrackIdentifier.new(:identifier => essence_track.identifier)
          essence_track_identifier.essence_track = essence_track
          essence_track_identifier.essence_track_identifier_source_id = essence_track.essence_track_identifier_source_id if essence_track.essence_track_identifier_source_id.present?
          essence_track_identifier.save(true)
        end
      end
    end
    
    remove_column :essence_tracks, :identifier
    remove_column :essence_tracks, :essence_track_identifier_source_id
    
  end

  def self.down
    add_column :essence_tracks, :essence_track_identifier_source_id, :integer
    add_column :essence_tracks, :identifier, :text,                         :limit => 16777215
    
    EssenceTrackIdentifier.find_in_batches do |batch|
      batch.each do |essence_track_identifier|
        essence_track = essence_track_identifier.essence_track
        essence_track.identifier = essence_track_identifier.identifier
        essence_track.essence_track_identifier_source_id = essence_track_identifier.essence_track_identifier_source_id
        essence_track.save
      end
    end
    
    drop_table :essence_track_identifiers
  end
end
