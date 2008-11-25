class UseMorePicklists < ActiveRecord::Migration
  def self.up
    create_table :essence_track_types do |t|
      t.string :name, :null => false
      t.boolean :visible, :null => false, :default => false
    end

    create_table :essence_track_identifier_sources do |t|
      t.string :name, :null => false
      t.boolean :visible, :null => false, :default => false
    end
    
    ["video", "audio", "text", "caption", "subtitle", "metadata", "sprite", "timecode"].each do |ett|
      EssenceTrackType.create(:name => ett, :visible => true)
    end
    
    rename_column(:essence_tracks, :essence_track_type, :tmp_column1)
    rename_column(:essence_tracks, :essence_track_identifier_source, :tmp_column2)
    add_column(:essence_tracks, :essence_track_type_id, :integer, :null => false)
    add_column(:essence_tracks, :essence_track_identifier_source_id, :integer, :null => false)
    EssenceTrack.all.each do |trk|
      trk.essence_track_type = EssenceTrackType.find_or_create_by_name(trk.tmp_column1)
      trk.essence_track_identifier_source = EssenceTrackIdentifierSource.find_or_create_by_name(trk.tmp_column2)
      trk.save
    end
    remove_column(:essence_tracks, :tmp_column1)
    remove_column(:essence_tracks, :tmp_column2)
    
    # ---
    
    create_table :format_identifier_sources do |t|
      t.string :name, :null => false
      t.boolean :visible, :null => false, :default => false
    end
    
    rename_column(:format_ids, :format_identifier_source, :tmp_column1)
    add_column(:format_ids, :format_identifier_source_id, :integer, :null => false)
    FormatId.all.each do |i|
      i.format_identifier_source = FormatIdentifierSource.find_or_create_by_name(i.tmp_column1)
      i.save
    end
    remove_column(:format_ids, :tmp_column1)
  end

  def self.down
    add_column(:essence_tracks, :tmp_column1, :string)
    add_column(:essence_tracks, :tmp_column2, :string)
    EssenceTrack.all.each do |trk|
      trk.tmp_column1 = trk.essence_track_type.name
      trk.tmp_column2 = trk.essence_track_identifier_source.name
      trk.save
    end
    remove_column(:essence_tracks, :essence_track_type_id)
    remove_column(:essence_tracks, :essence_track_identifier_source_id)
    rename_column(:essence_tracks, :tmp_column1, :essence_track_type)
    rename_column(:essence_tracks, :tmp_column2, :essence_track_identifier_source)
    
    add_column(:format_ids, :tmp_column1, :string)
    FormatId.all.each do |f|
      f.tmp_column1 = f.format_identifier_source.name
      f.save
    end
    remove_column(:format_ids, :format_identifier_source_id)
    rename_column(:format_ids, :tmp_column1, :format_identifier_source)
    
    drop_table :essence_track_types
    drop_table :essence_track_identifier_sources
    drop_table :format_identifier_sources
  end
end
