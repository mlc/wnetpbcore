# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080923055831) do

  create_table "annotation", :force => true do |t|
    t.integer "instantiation_id"
    t.text    "annotation"
  end

  add_index "annotation", ["instantiation_id"], :name => "index_annotation_on_instantiation_id"

  create_table "assets", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assets_audience_levels", :id => false, :force => true do |t|
    t.integer "asset_id"
    t.integer "asset_level_id"
  end

  add_index "assets_audience_levels", ["asset_id"], :name => "index_assets_audience_levels_on_asset_id"

  create_table "assets_audience_ratings", :id => false, :force => true do |t|
    t.integer "asset_id"
    t.integer "audience_rating_id"
  end

  add_index "assets_audience_ratings", ["asset_id"], :name => "index_assets_audience_ratings_on_asset_id"

  create_table "audience_levels", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "audience_ratings", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "contributor_roles", :force => true do |t|
    t.string "name", :null => false
  end

  add_index "contributor_roles", ["name"], :name => "index_contributor_roles_on_name"

  create_table "contributors", :force => true do |t|
    t.integer  "asset_id"
    t.string   "contributor",         :null => false
    t.integer  "contributor_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contributors", ["contributor"], :name => "index_contributors_on_contributor"
  add_index "contributors", ["asset_id"], :name => "index_contributors_on_asset_id"

  create_table "coverages", :force => true do |t|
    t.integer  "asset_id"
    t.text     "coverage",      :null => false
    t.string   "coverage_type", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "creator_roles", :force => true do |t|
    t.string "name", :null => false
  end

  add_index "creator_roles", ["name"], :name => "index_creator_roles_on_name"

  create_table "creators", :force => true do |t|
    t.integer  "asset_id"
    t.string   "creator",         :null => false
    t.integer  "creator_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "creators", ["creator"], :name => "index_creators_on_creator"
  add_index "creators", ["asset_id"], :name => "index_creators_on_asset_id"

  create_table "date_availables", :force => true do |t|
    t.integer "instantiation_id"
    t.string  "date_available_start"
    t.string  "date_available_end"
  end

  add_index "date_availables", ["instantiation_id"], :name => "index_date_availables_on_instantiation_id"

  create_table "description_types", :force => true do |t|
    t.string "name"
  end

  add_index "description_types", ["name"], :name => "index_description_types_on_name"

  create_table "descriptions", :force => true do |t|
    t.integer  "asset_id"
    t.string   "description",         :null => false
    t.integer  "description_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "descriptions", ["asset_id"], :name => "index_descriptions_on_asset_id"

  create_table "essence_tracks", :force => true do |t|
    t.integer "instantiation_id"
    t.string  "essence_track_identifier"
    t.string  "essence_track_identifier_source"
    t.string  "essence_track_standard"
    t.string  "essence_track_encoding"
    t.string  "essence_track_data_rate"
    t.string  "essence_track_time_start"
    t.string  "essence_track_duration"
    t.string  "essence_track_bit_depth"
    t.string  "essence_track_sampling_rate"
    t.string  "essence_track_frame_size"
    t.string  "essence_track_aspect_ratio"
    t.string  "essence_track_frame_rate"
    t.string  "essence_track_language"
    t.text    "essence_track_annotation"
  end

  add_index "essence_tracks", ["instantiation_id"], :name => "index_essence_tracks_on_instantiation_id"

  create_table "extensions", :force => true do |t|
    t.integer "asset_id"
    t.text    "extension"
    t.text    "extension_authority_used"
  end

  add_index "extensions", ["asset_id"], :name => "index_extensions_on_asset_id"

  create_table "format_colors", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "format_generations", :force => true do |t|
    t.string "name", :null => false
  end

  add_index "format_generations", ["name"], :name => "index_format_generations_on_name"

  create_table "format_ids", :force => true do |t|
    t.integer  "instantiation_id"
    t.string   "format_identifier",        :null => false
    t.string   "format_identifier_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "format_ids", ["instantiation_id"], :name => "index_format_ids_on_instantiation_id"

  create_table "format_media_types", :force => true do |t|
    t.string "name", :null => false
  end

  add_index "format_media_types", ["name"], :name => "index_format_media_types_on_name"

  create_table "formats", :force => true do |t|
    t.string "type", :null => false
    t.string "name", :null => false
  end

  add_index "formats", ["type", "name"], :name => "index_formats_on_type_and_name"

  create_table "genres", :force => true do |t|
    t.integer  "asset_id"
    t.string   "genre",                :null => false
    t.string   "genre_authority_used"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "genres", ["genre"], :name => "index_genres_on_genre"
  add_index "genres", ["asset_id"], :name => "index_genres_on_asset_id"

  create_table "identifier_sources", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "identifiers", :force => true do |t|
    t.integer  "asset_id"
    t.string   "identifier",           :null => false
    t.integer  "identifier_source_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identifiers", ["identifier", "identifier_source_id"], :name => "index_identifiers_on_identifier_and_identifier_source_id"
  add_index "identifiers", ["asset_id"], :name => "index_identifiers_on_asset_id"

  create_table "instantiations", :force => true do |t|
    t.integer  "asset_id"
    t.string   "date_created"
    t.string   "date_issued"
    t.integer  "format_id"
    t.string   "format_location",              :null => false
    t.integer  "format_media_type_id"
    t.integer  "format_generation_id"
    t.string   "format_file_size"
    t.string   "format_time_start"
    t.string   "format_duration"
    t.string   "format_data_rate"
    t.integer  "format_color_id"
    t.text     "format_tracks"
    t.text     "format_channel_configuration"
    t.string   "language"
    t.text     "alternative_modes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "instantiations", ["asset_id"], :name => "index_instantiations_on_asset_id"

  create_table "publisher_roles", :force => true do |t|
    t.string "name", :null => false
  end

  add_index "publisher_roles", ["name"], :name => "index_publisher_roles_on_name"

  create_table "publishers", :force => true do |t|
    t.integer  "asset_id"
    t.string   "publisher",         :null => false
    t.integer  "publisher_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "publishers", ["asset_id"], :name => "index_publishers_on_asset_id"

  create_table "relation_types", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "relations", :force => true do |t|
    t.integer  "asset_id"
    t.integer  "relation_type_id"
    t.string   "relation_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relations", ["relation_identifier"], :name => "index_relations_on_relation_identifier"
  add_index "relations", ["asset_id"], :name => "index_relations_on_asset_id"

  create_table "rights_summaries", :force => true do |t|
    t.integer  "asset_id"
    t.text     "rights_summary", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rights_summaries", ["asset_id"], :name => "index_rights_summaries_on_asset_id"

  create_table "subjects", :force => true do |t|
    t.integer  "asset_id"
    t.string   "subject",           :null => false
    t.string   "subject_authority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subjects", ["subject"], :name => "index_subjects_on_subject"
  add_index "subjects", ["asset_id"], :name => "index_subjects_on_asset_id"

  create_table "title_type_categories", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "title_types", :force => true do |t|
    t.string  "name",        :null => false
    t.integer "category_id"
  end

  add_index "title_types", ["name"], :name => "index_title_types_on_name"

  create_table "titles", :force => true do |t|
    t.integer  "asset_id"
    t.string   "title",         :null => false
    t.integer  "title_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "titles", ["title_type_id"], :name => "index_titles_on_title_type_id"
  add_index "titles", ["asset_id"], :name => "index_titles_on_asset_id"

end
