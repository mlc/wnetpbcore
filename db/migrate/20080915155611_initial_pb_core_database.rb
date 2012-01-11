class InitialPbCoreDatabase < ActiveRecord::Migration
  def self.up
    create_table "assets" do |t|
      t.timestamps
    end

    create_table "identifiers" do |t|
      t.integer :asset_id
      t.string :identifier, :null => false
      t.integer :identifier_source_id
      t.timestamps
    end
    add_index :identifiers, :asset_id
    add_index :identifiers, [:identifier, :identifier_source_id]

    create_table "identifier_sources" do |t|
      t.column :name, :text, :null => false
      t.timestamps
    end

    create_table "titles" do |t|
      t.integer :asset_id
      t.text :title, :null => false
      t.integer :title_type_id
      t.timestamps
    end
    add_index :titles, :asset_id
    add_index :titles, :title_type_id

    create_table "title_types" do |t|
      t.column :name, :string, :null => false
      t.column :category_id, :int
    end
    add_index :title_types, :name

    create_table "title_type_categories" do |t|
      t.column :name, :string, :null => false
    end

    create_table "subjects" do |t|
      t.integer :asset_id
      t.text :subject
      t.text :subject_authority
      t.timestamps
    end
    add_index :subjects, :asset_id

    create_table "descriptions" do |t|
      t.integer :asset_id
      t.text :description, :null => false
      t.integer :description_type_id
      t.timestamps
    end
    add_index :descriptions, :asset_id

    create_table "description_types" do |t|
      t.column :name, :string
    end
    add_index :description_types, :name

    create_table :genres do |t|
      t.integer :asset_id
      t.text :genre, :null => false
      t.text :genre_authority_used
      t.timestamps
    end
    add_index :genres, :asset_id

    create_table :relations do |t|
      t.integer :asset_id
      t.integer :relation_type_id
      t.string :relation_identifier
      t.timestamps
    end
    add_index :relations, :asset_id
    add_index :relations, :relation_identifier

    create_table :relation_types do |t|
      t.text :name, :null => false
    end

    create_table :coverages do |t|
      t.integer :asset_id
      t.text :coverage, :null => false
      t.string :coverage_type, :null => false # 'spatial' or 'temporal'
      t.timestamps
    end

    create_table :audience_levels do |t|
      t.string :name, :null => false
    end

    create_table :assets_audience_levels, :id => false do |t|
      t.integer :asset_id
      t.integer :audience_level_id
    end
    add_index :assets_audience_levels, :asset_id

    create_table :audience_ratings do |t|
      t.string :name, :null => false
    end

    create_table :assets_audience_ratings, :id => false do |t|
      t.integer :asset_id
      t.integer :audience_rating_id
    end
    add_index :assets_audience_ratings, :asset_id

    create_table :creators do |t|
      t.integer :asset_id
      t.text :creator, :null => false
      t.integer :creator_role_id
      t.timestamps
    end
    add_index :creators, :asset_id

    create_table :creator_roles do |t|
      t.string :name, :null => false
    end
    add_index :creator_roles, :name

    create_table :contributors do |t|
      t.integer :asset_id
      t.text :contributor, :null => false
      t.integer :contributor_role_id
      t.timestamps
    end
    add_index :contributors, :asset_id

    create_table :contributor_roles do |t|
      t.string :name, :null => false
    end
    add_index :contributor_roles, :name

    create_table :publishers do |t|
      t.integer :asset_id
      t.text :publisher, :null => false
      t.integer :publisher_role_id
      t.timestamps
    end
    add_index :publishers, :asset_id

    create_table :publisher_roles do |t|
      t.string :name, :null => false
    end
    add_index :publisher_roles, :name

    create_table :rights_summaries do |t|
      t.integer :asset_id
      t.text :rights_summary, :null => false
      t.timestamps
    end
    add_index :rights_summaries, :asset_id

    create_table :instantiations do |t|
      t.integer :asset_id
      t.string :date_created
      t.string :date_issued
      t.integer :format_id
      t.text :format_location, :null => false
      t.integer :format_media_type
      t.integer :format_generation_id
      t.string :format_file_size
      t.string :format_time_start
      t.string :format_duration
      t.string :format_data_rate
      t.integer :format_color_id
      t.text :format_tracks
      t.text :format_channel_configuration
      t.string :language
      t.text :alternative_modes
      t.timestamps
    end
    add_index :instantiations, :asset_id

    create_table :format_ids do |t|
      t.integer :instantiation_id
      t.text :format_identifier, :null => false
      t.text :format_identifier_source
      t.timestamps
    end
    add_index :format_ids, :instantiation_id

    create_table :formats do |t|
      t.string :type, :null => false # STI
      t.string :name, :null => false
    end
    add_index :formats, [:type, :name]

    create_table :format_media_types do |t|
      t.string :name, :null => false
    end
    add_index :format_media_types, :name

    create_table :format_generations do |t|
      t.string :name, :null => false
    end
    add_index :format_generations, :name

    create_table :format_colors do |t|
      t.string :name, :null => false
    end

    create_table :essence_tracks do |t|
      t.integer :instantiation_id
      # these are not documented yet...
      # maybe some should eventually be lookup tables...
      t.text :essence_track_type
      t.text :essence_track_identifier
      t.text :essence_track_identifier_source
      t.text :essence_track_standard
      t.text :essence_track_encoding
      t.text :essence_track_data_rate
      t.text :essence_track_time_start
      t.text :essence_track_duration
      t.text :essence_track_bit_depth
      t.text :essence_track_sampling_rate
      t.text :essence_track_frame_size
      t.text :essence_track_aspect_ratio
      t.text :essence_track_frame_rate
      t.text :essence_track_language
      t.text :essence_track_annotation
    end
    add_index :essence_tracks, :instantiation_id

    create_table :date_availables do |t|
      t.integer :instantiation_id
      t.string :date_available_start
      t.string :date_available_end
    end
    add_index :date_availables, :instantiation_id

    create_table :annotation do |t|
      t.integer :instantiation_id
      t.text :annotation
    end
    add_index :annotation, :instantiation_id

    create_table :extensions do |t|
      t.integer :asset_id
      t.text :extension
      t.text :extension_authority_used
    end
    add_index :extensions, :asset_id
  end

  def self.down
    [
      :annotation, :assets, :assets_audience_levels, :assets_audience_ratings,
      :audience_levels, :audience_ratings, :contributor_roles, :contributors,
      :coverages, :creator_roles, :creators, :date_availables,
      :description_types, :descriptions, :essence_tracks, :extensions,
      :format_colors, :format_generations, :format_ids, :format_media_types,
      :formats, :genres, :identifier_sources, :identifiers, :instantiations,
      :publisher_roles, :publishers, :relation_types, :relations,
      :rights_summaries, :subjects, :title_type_categories, :title_types,
      :titles
    ].each do |t|
      drop_table t
    end
  end
end
