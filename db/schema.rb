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

ActiveRecord::Schema.define(:version => 20120116210456) do

  create_table "annotations", :force => true do |t|
    t.integer "container_id"
    t.text    "annotation",      :limit => 2147483647
    t.text    "annotation_type"
    t.text    "ref"
    t.string  "container_type"
  end

  add_index "annotations", ["container_id", "container_type"], :name => "index_annotations_on_container_id_and_container_type"
  add_index "annotations", ["container_id"], :name => "index_annotation_on_instantiation_id"

  create_table "asset_date_types", :force => true do |t|
    t.string  "name"
    t.boolean "visible", :default => false, :null => false
  end

  create_table "asset_dates", :force => true do |t|
    t.integer  "asset_id"
    t.integer  "asset_date_type_id"
    t.text     "asset_date"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.boolean  "visible",            :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "asset_dates", ["asset_id"], :name => "index_asset_dates_on_asset_id"

  create_table "assets", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid",       :limit => 36, :null => false
    t.integer  "creator_id"
    t.integer  "updater_id"
  end

  add_index "assets", ["uuid"], :name => "index_assets_on_uuid", :unique => true

  create_table "assets_audience_levels", :id => false, :force => true do |t|
    t.integer "asset_id"
    t.integer "audience_level_id"
  end

  add_index "assets_audience_levels", ["asset_id"], :name => "index_assets_audience_levels_on_asset_id"

  create_table "assets_audience_ratings", :id => false, :force => true do |t|
    t.integer "asset_id"
    t.integer "audience_rating_id"
  end

  add_index "assets_audience_ratings", ["asset_id"], :name => "index_assets_audience_ratings_on_asset_id"

  create_table "assets_genres", :id => false, :force => true do |t|
    t.integer "asset_id", :null => false
    t.integer "genre_id", :null => false
  end

  add_index "assets_genres", ["asset_id"], :name => "index_assets_genres_on_asset_id"

  create_table "assets_subjects", :id => false, :force => true do |t|
    t.integer "asset_id",   :null => false
    t.integer "subject_id", :null => false
  end

  add_index "assets_subjects", ["asset_id"], :name => "index_assets_subjects_on_asset_id"

  create_table "audience_levels", :force => true do |t|
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  create_table "audience_ratings", :force => true do |t|
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  create_table "borrowings", :force => true do |t|
    t.integer  "instantiation_id", :null => false
    t.string   "person",           :null => false
    t.string   "department"
    t.datetime "borrowed"
    t.datetime "returned"
  end

  add_index "borrowings", ["instantiation_id"], :name => "index_borrowings_on_instantiation_id"

  create_table "contributor_roles", :force => true do |t|
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  add_index "contributor_roles", ["name"], :name => "index_contributor_roles_on_name"

  create_table "contributors", :force => true do |t|
    t.integer  "asset_id"
    t.text     "contributor",         :limit => 2147483647, :null => false
    t.integer  "contributor_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.text     "affiliation"
    t.text     "ref"
    t.text     "annotation"
    t.text     "start_time"
    t.text     "end_time"
    t.text     "time_annotation"
    t.text     "role_portrayal"
    t.text     "source"
  end

  add_index "contributors", ["asset_id"], :name => "index_contributors_on_asset_id"

  create_table "coverages", :force => true do |t|
    t.integer  "asset_id"
    t.text     "coverage",        :limit => 2147483647, :null => false
    t.string   "coverage_type",                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.text     "source"
    t.text     "ref"
    t.text     "annotation"
    t.text     "start_time"
    t.text     "end_time"
    t.text     "time_annotation"
  end

  add_index "coverages", ["asset_id"], :name => "index_coverages_on_asset_id"

  create_table "creator_roles", :force => true do |t|
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  add_index "creator_roles", ["name"], :name => "index_creator_roles_on_name"

  create_table "creators", :force => true do |t|
    t.integer  "asset_id"
    t.text     "creator",         :limit => 2147483647, :null => false
    t.integer  "creator_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.text     "affiliation"
    t.text     "ref"
    t.text     "annotation"
    t.text     "start_time"
    t.text     "end_time"
    t.text     "time_annotation"
    t.text     "source"
  end

  add_index "creators", ["asset_id"], :name => "index_creators_on_asset_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",                         :default => 0
    t.integer  "attempts",                         :default => 0
    t.text     "handler",    :limit => 2147483647
    t.text     "last_error", :limit => 2147483647
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "description_types", :force => true do |t|
    t.string  "name"
    t.boolean "visible", :default => false, :null => false
  end

  add_index "description_types", ["name"], :name => "index_description_types_on_name"

  create_table "descriptions", :force => true do |t|
    t.integer  "asset_id"
    t.text     "description",                 :limit => 2147483647, :null => false
    t.integer  "description_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.text     "description_type_source"
    t.text     "description_type_ref"
    t.text     "description_type_annotation"
    t.text     "segment_type"
    t.text     "segment_type_source"
    t.text     "segment_type_ref"
    t.text     "segment_type_annotation"
    t.text     "start_time"
    t.text     "end_time"
    t.text     "time_annotation"
    t.text     "annotation"
  end

  add_index "descriptions", ["asset_id"], :name => "index_descriptions_on_asset_id"

  create_table "essence_track_identifier_sources", :force => true do |t|
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  create_table "essence_track_identifiers", :force => true do |t|
    t.integer  "essence_track_id"
    t.text     "identifier"
    t.integer  "essence_track_identifier_source_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "essence_track_identifiers", ["essence_track_id"], :name => "index_essence_track_identifiers_on_essence_track_id"

  create_table "essence_track_types", :force => true do |t|
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  create_table "essence_tracks", :force => true do |t|
    t.integer "instantiation_id"
    t.text    "standard",                        :limit => 2147483647
    t.text    "encoding",                        :limit => 2147483647
    t.text    "data_rate",                       :limit => 2147483647
    t.text    "time_start",                      :limit => 2147483647
    t.text    "duration",                        :limit => 2147483647
    t.text    "bit_depth",                       :limit => 2147483647
    t.text    "sampling_rate",                   :limit => 2147483647
    t.text    "frame_size",                      :limit => 2147483647
    t.text    "aspect_ratio",                    :limit => 2147483647
    t.text    "frame_rate",                      :limit => 2147483647
    t.text    "language",                        :limit => 2147483647
    t.text    "annotation",                      :limit => 2147483647
    t.integer "essence_track_type_id"
    t.string  "playback_speed"
    t.string  "playback_speed_units_of_measure"
    t.string  "sampling_rate_units_of_measure"
  end

  add_index "essence_tracks", ["instantiation_id"], :name => "index_essence_tracks_on_instantiation_id"

  create_table "exports", :force => true do |t|
    t.string   "status"
    t.string   "file"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "extension_names", :force => true do |t|
    t.string   "extension_key"
    t.string   "extension_authority"
    t.text     "description",         :limit => 2147483647
    t.boolean  "visible",                                   :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
  end

  add_index "extension_names", ["extension_authority", "extension_key"], :name => "index_extension_names_on_extension_authority_and_extension_key", :unique => true

  create_table "extensions", :force => true do |t|
    t.integer "asset_id"
    t.text    "extension",                :limit => 2147483647
    t.text    "extension_authority_used", :limit => 2147483647
  end

  add_index "extensions", ["asset_id"], :name => "index_extensions_on_asset_id"

  create_table "format_identifier_sources", :force => true do |t|
    t.string  "name",                          :null => false
    t.boolean "visible",    :default => false, :null => false
    t.string  "regex"
    t.boolean "auto_merge", :default => false
  end

  create_table "format_ids", :force => true do |t|
    t.integer  "instantiation_id"
    t.string   "format_identifier",           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "format_identifier_source_id", :null => false
    t.integer  "creator_id"
    t.integer  "updater_id"
  end

  add_index "format_ids", ["format_identifier_source_id", "format_identifier"], :name => "by_source_and_identifier"
  add_index "format_ids", ["instantiation_id"], :name => "index_format_ids_on_instantiation_id"

  create_table "formats", :force => true do |t|
    t.string  "type",                       :null => false
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  add_index "formats", ["type", "name"], :name => "index_formats_on_type_and_name"

  create_table "genres", :force => true do |t|
    t.text     "name",                 :limit => 2147483647,                    :null => false
    t.text     "genre_authority_used", :limit => 2147483647
    t.boolean  "visible",                                    :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.string   "ref"
  end

  create_table "identifier_sources", :force => true do |t|
    t.text     "name",          :limit => 2147483647,                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "visible",                             :default => false, :null => false
    t.boolean  "show_in_index",                       :default => true,  :null => false
    t.string   "regex"
    t.boolean  "auto_merge",                          :default => false, :null => false
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "sequence"
  end

  create_table "identifiers", :force => true do |t|
    t.integer  "asset_id"
    t.string   "identifier",           :null => false
    t.integer  "identifier_source_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.text     "ref"
    t.text     "annotation"
  end

  add_index "identifiers", ["asset_id"], :name => "index_identifiers_on_asset_id"
  add_index "identifiers", ["identifier_source_id", "identifier"], :name => "index_identifiers_on_identifier_source_id_and_identifier"

  create_table "instantiation_colors", :force => true do |t|
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  create_table "instantiation_date_types", :force => true do |t|
    t.string  "name"
    t.boolean "visible", :default => false, :null => false
  end

  create_table "instantiation_dates", :force => true do |t|
    t.integer  "instantiation_id",           :null => false
    t.integer  "instantiation_date_type_id"
    t.text     "date"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "instantiation_dates", ["instantiation_id"], :name => "index_instantiation_dates_on_instantiation_id"

  create_table "instantiation_dimensions", :force => true do |t|
    t.integer  "instantiation_id"
    t.string   "dimension"
    t.string   "units_of_measure"
    t.text     "annotation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instantiation_generations", :force => true do |t|
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  add_index "instantiation_generations", ["name"], :name => "index_format_generations_on_name"

  create_table "instantiation_generations_instantiations", :id => false, :force => true do |t|
    t.integer "instantiation_id"
    t.integer "instantiation_generation_id"
  end

  create_table "instantiation_media_types", :force => true do |t|
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  add_index "instantiation_media_types", ["name"], :name => "index_format_media_types_on_name"

  create_table "instantiation_relations", :force => true do |t|
    t.integer  "instantiation_id"
    t.string   "instantiation_relation_identifier"
    t.integer  "relation_type_id"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instantiation_rights_summaries", :force => true do |t|
    t.integer  "instantiation_id"
    t.text     "rights_summary"
    t.text     "source"
    t.text     "ref"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instantiations", :force => true do |t|
    t.integer  "asset_id"
    t.integer  "format_id"
    t.text     "format_location",                   :limit => 2147483647,                    :null => false
    t.integer  "instantiation_media_type_id"
    t.string   "format_file_size"
    t.string   "format_time_start"
    t.string   "format_duration"
    t.string   "format_data_rate"
    t.integer  "instantiation_color_id"
    t.text     "format_tracks",                     :limit => 2147483647
    t.text     "format_channel_configuration",      :limit => 2147483647
    t.string   "language"
    t.text     "alternative_modes",                 :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid",                              :limit => 36,                            :null => false
    t.string   "template_name"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.text     "start_time"
    t.text     "end_time"
    t.text     "time_annotation"
    t.string   "format_data_rate_units_of_measure"
    t.string   "format_file_size_units_of_measure"
    t.text     "standard"
    t.text     "standard_source"
    t.text     "standard_ref"
    t.boolean  "digitized",                                               :default => false
  end

  add_index "instantiations", ["asset_id"], :name => "index_instantiations_on_asset_id"
  add_index "instantiations", ["template_name"], :name => "index_instantiations_on_template_name"
  add_index "instantiations", ["uuid"], :name => "index_instantiations_on_uuid", :unique => true

  create_table "ip_blocks", :force => true do |t|
    t.string "name",                         :null => false
    t.text   "ranges", :limit => 2147483647
  end

  add_index "ip_blocks", ["name"], :name => "index_ip_blocks_on_name", :unique => true

  create_table "pbcore_importers", :force => true do |t|
    t.string   "file"
    t.integer  "number_of_records"
    t.integer  "number_of_records_processed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "publisher_roles", :force => true do |t|
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  add_index "publisher_roles", ["name"], :name => "index_publisher_roles_on_name"

  create_table "publishers", :force => true do |t|
    t.integer  "asset_id"
    t.text     "publisher",         :limit => 2147483647, :null => false
    t.integer  "publisher_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.text     "affiliation"
    t.text     "ref"
    t.text     "annotation"
    t.text     "start_time"
    t.text     "end_time"
    t.text     "time_annotation"
    t.text     "source"
  end

  add_index "publishers", ["asset_id"], :name => "index_publishers_on_asset_id"

  create_table "relation_types", :force => true do |t|
    t.text    "name",    :limit => 2147483647,                    :null => false
    t.boolean "visible",                       :default => false, :null => false
    t.text    "ref"
  end

  create_table "relations", :force => true do |t|
    t.integer  "asset_id"
    t.integer  "relation_type_id"
    t.string   "relation_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.text     "source"
    t.text     "ref"
    t.text     "annotation"
  end

  add_index "relations", ["asset_id"], :name => "index_relations_on_asset_id"
  add_index "relations", ["relation_identifier"], :name => "index_relations_on_relation_identifier"

  create_table "rights_summaries", :force => true do |t|
    t.integer  "asset_id"
    t.text     "rights_summary", :limit => 2147483647, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.text     "source"
    t.text     "ref"
  end

  add_index "rights_summaries", ["asset_id"], :name => "index_rights_summaries_on_asset_id"

  create_table "subjects", :force => true do |t|
    t.text     "subject",           :limit => 2147483647,                    :null => false
    t.text     "subject_authority", :limit => 2147483647
    t.boolean  "visible",                                 :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.string   "ref"
  end

  create_table "title_type_categories", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "title_types", :force => true do |t|
    t.string  "name",                           :null => false
    t.integer "category_id"
    t.boolean "visible",     :default => false, :null => false
  end

  add_index "title_types", ["name"], :name => "index_title_types_on_name"

  create_table "titles", :force => true do |t|
    t.integer  "asset_id"
    t.text     "title",           :limit => 2147483647, :null => false
    t.integer  "title_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.text     "source"
    t.text     "ref"
    t.text     "annotation"
    t.text     "start_time"
    t.text     "end_time"
    t.text     "time_annotation"
  end

  add_index "titles", ["asset_id"], :name => "index_titles_on_asset_id"
  add_index "titles", ["title_type_id"], :name => "index_titles_on_title_type_id"

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.integer  "ip_block_id"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.string   "role",                                     :default => "user", :null => false
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

  create_table "value_lists", :force => true do |t|
    t.string "category", :null => false
    t.string "value",    :null => false
  end

  add_index "value_lists", ["category", "value"], :name => "index_value_lists_on_category_and_value", :unique => true

  create_table "values", :force => true do |t|
    t.integer "value_list_id", :null => false
    t.string  "value",         :null => false
  end

  add_index "values", ["value_list_id", "value"], :name => "index_values_on_value_list_id_and_value", :unique => true

  create_table "versions", :force => true do |t|
    t.integer  "asset_id",   :null => false
    t.text     "body"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "versions", ["asset_id"], :name => "index_versions_on_asset_id"

end
