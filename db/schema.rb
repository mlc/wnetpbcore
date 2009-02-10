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

ActiveRecord::Schema.define(:version => 20090210222857) do

  create_table "annotations", :force => true do |t|
    t.integer "instantiation_id", :limit => 11
    t.text    "annotation",       :limit => 16777215
  end

  add_index "annotations", ["instantiation_id"], :name => "index_annotation_on_instantiation_id"

  create_table "asset_terms", :force => true do |t|
    t.integer  "asset_id",        :limit => 11, :null => false
    t.text     "identifier"
    t.text     "title"
    t.text     "subject"
    t.text     "description"
    t.text     "genre"
    t.text     "relation"
    t.text     "coverage"
    t.text     "audience_level"
    t.text     "audience_rating"
    t.text     "creator"
    t.text     "contributor"
    t.text     "publisher"
    t.text     "rights"
    t.text     "extension"
    t.text     "location"
    t.text     "annotation"
    t.text     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta",                         :null => false
  end

  add_index "asset_terms", ["asset_id"], :name => "index_asset_terms_on_asset_id", :unique => true

  create_table "assets", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid",       :limit => 36, :null => false
  end

  add_index "assets", ["uuid"], :name => "index_assets_on_uuid", :unique => true

  create_table "assets_audience_levels", :id => false, :force => true do |t|
    t.integer "asset_id",          :limit => 11
    t.integer "audience_level_id", :limit => 11
  end

  add_index "assets_audience_levels", ["asset_id"], :name => "index_assets_audience_levels_on_asset_id"

  create_table "assets_audience_ratings", :id => false, :force => true do |t|
    t.integer "asset_id",           :limit => 11
    t.integer "audience_rating_id", :limit => 11
  end

  add_index "assets_audience_ratings", ["asset_id"], :name => "index_assets_audience_ratings_on_asset_id"

  create_table "assets_genres", :id => false, :force => true do |t|
    t.integer "asset_id", :limit => 11, :null => false
    t.integer "genre_id", :limit => 11, :null => false
  end

  add_index "assets_genres", ["asset_id"], :name => "index_assets_genres_on_asset_id"

  create_table "assets_subjects", :id => false, :force => true do |t|
    t.integer "asset_id",   :limit => 11, :null => false
    t.integer "subject_id", :limit => 11, :null => false
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

  create_table "bdrb_job_queues", :force => true do |t|
    t.binary   "args"
    t.string   "worker_name"
    t.string   "worker_method"
    t.string   "job_key"
    t.integer  "taken",          :limit => 11
    t.integer  "finished",       :limit => 11
    t.integer  "timeout",        :limit => 11
    t.integer  "priority",       :limit => 11
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "archived_at"
    t.string   "tag"
    t.string   "submitter_info"
    t.string   "runner_info"
    t.string   "worker_key"
    t.datetime "scheduled_at"
  end

  create_table "contributor_roles", :force => true do |t|
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  add_index "contributor_roles", ["name"], :name => "index_contributor_roles_on_name"

  create_table "contributors", :force => true do |t|
    t.integer  "asset_id",            :limit => 11
    t.text     "contributor",         :limit => 16777215, :null => false
    t.integer  "contributor_role_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contributors", ["asset_id"], :name => "index_contributors_on_asset_id"

  create_table "coverages", :force => true do |t|
    t.integer  "asset_id",      :limit => 11
    t.text     "coverage",      :limit => 16777215, :null => false
    t.string   "coverage_type",                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coverages", ["asset_id"], :name => "index_coverages_on_asset_id"

  create_table "creator_roles", :force => true do |t|
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  add_index "creator_roles", ["name"], :name => "index_creator_roles_on_name"

  create_table "creators", :force => true do |t|
    t.integer  "asset_id",        :limit => 11
    t.text     "creator",         :limit => 16777215, :null => false
    t.integer  "creator_role_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "creators", ["asset_id"], :name => "index_creators_on_asset_id"

  create_table "date_availables", :force => true do |t|
    t.integer "instantiation_id",     :limit => 11
    t.string  "date_available_start"
    t.string  "date_available_end"
  end

  add_index "date_availables", ["instantiation_id"], :name => "index_date_availables_on_instantiation_id"

  create_table "description_types", :force => true do |t|
    t.string  "name"
    t.boolean "visible", :default => false, :null => false
  end

  add_index "description_types", ["name"], :name => "index_description_types_on_name"

  create_table "descriptions", :force => true do |t|
    t.integer  "asset_id",            :limit => 11
    t.text     "description",         :limit => 16777215, :null => false
    t.integer  "description_type_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "descriptions", ["asset_id"], :name => "index_descriptions_on_asset_id"

  create_table "essence_track_identifier_sources", :force => true do |t|
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  create_table "essence_track_types", :force => true do |t|
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  create_table "essence_tracks", :force => true do |t|
    t.integer "instantiation_id",                   :limit => 11
    t.text    "essence_track_identifier",           :limit => 16777215
    t.text    "essence_track_standard",             :limit => 16777215
    t.text    "essence_track_encoding",             :limit => 16777215
    t.text    "essence_track_data_rate",            :limit => 16777215
    t.text    "essence_track_time_start",           :limit => 16777215
    t.text    "essence_track_duration",             :limit => 16777215
    t.text    "essence_track_bit_depth",            :limit => 16777215
    t.text    "essence_track_sampling_rate",        :limit => 16777215
    t.text    "essence_track_frame_size",           :limit => 16777215
    t.text    "essence_track_aspect_ratio",         :limit => 16777215
    t.text    "essence_track_frame_rate",           :limit => 16777215
    t.text    "essence_track_language",             :limit => 16777215
    t.text    "essence_track_annotation",           :limit => 16777215
    t.integer "essence_track_type_id",              :limit => 11,       :null => false
    t.integer "essence_track_identifier_source_id", :limit => 11,       :null => false
  end

  add_index "essence_tracks", ["instantiation_id"], :name => "index_essence_tracks_on_instantiation_id"

  create_table "extension_names", :force => true do |t|
    t.string   "extension_key"
    t.string   "extension_authority"
    t.text     "description"
    t.boolean  "visible",             :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "extension_names", ["extension_authority", "extension_key"], :name => "index_extension_names_on_extension_authority_and_extension_key", :unique => true

  create_table "extensions", :force => true do |t|
    t.integer "asset_id",                 :limit => 11
    t.text    "extension",                :limit => 16777215
    t.text    "extension_authority_used", :limit => 16777215
  end

  add_index "extensions", ["asset_id"], :name => "index_extensions_on_asset_id"

  create_table "format_colors", :force => true do |t|
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  create_table "format_generations", :force => true do |t|
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  add_index "format_generations", ["name"], :name => "index_format_generations_on_name"

  create_table "format_identifier_sources", :force => true do |t|
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
    t.string  "regex"
  end

  create_table "format_ids", :force => true do |t|
    t.integer  "instantiation_id",            :limit => 11
    t.text     "format_identifier",           :limit => 16777215, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "format_identifier_source_id", :limit => 11,       :null => false
  end

  add_index "format_ids", ["instantiation_id"], :name => "index_format_ids_on_instantiation_id"

  create_table "format_media_types", :force => true do |t|
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  add_index "format_media_types", ["name"], :name => "index_format_media_types_on_name"

  create_table "formats", :force => true do |t|
    t.string  "type",                       :null => false
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  add_index "formats", ["type", "name"], :name => "index_formats_on_type_and_name"

  create_table "genres", :force => true do |t|
    t.text     "name",                                    :null => false
    t.text     "genre_authority_used"
    t.boolean  "visible",              :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "identifier_sources", :force => true do |t|
    t.text     "name",          :limit => 16777215,                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "visible",                           :default => false, :null => false
    t.boolean  "show_in_index",                     :default => true,  :null => false
    t.string   "regex"
  end

  create_table "identifiers", :force => true do |t|
    t.integer  "asset_id",             :limit => 11
    t.string   "identifier",                         :null => false
    t.integer  "identifier_source_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identifiers", ["asset_id"], :name => "index_identifiers_on_asset_id"
  add_index "identifiers", ["identifier", "identifier_source_id"], :name => "index_identifiers_on_identifier_and_identifier_source_id"

  create_table "instantiations", :force => true do |t|
    t.integer  "asset_id",                     :limit => 11
    t.string   "date_created"
    t.string   "date_issued"
    t.integer  "format_id",                    :limit => 11
    t.text     "format_location",              :limit => 16777215, :null => false
    t.integer  "format_media_type_id",         :limit => 11
    t.integer  "format_generation_id",         :limit => 11
    t.string   "format_file_size"
    t.string   "format_time_start"
    t.string   "format_duration"
    t.string   "format_data_rate"
    t.integer  "format_color_id",              :limit => 11
    t.text     "format_tracks",                :limit => 16777215
    t.text     "format_channel_configuration", :limit => 16777215
    t.string   "language"
    t.text     "alternative_modes",            :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "instantiations", ["asset_id"], :name => "index_instantiations_on_asset_id"

  create_table "publisher_roles", :force => true do |t|
    t.string  "name",                       :null => false
    t.boolean "visible", :default => false, :null => false
  end

  add_index "publisher_roles", ["name"], :name => "index_publisher_roles_on_name"

  create_table "publishers", :force => true do |t|
    t.integer  "asset_id",          :limit => 11
    t.text     "publisher",         :limit => 16777215, :null => false
    t.integer  "publisher_role_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "publishers", ["asset_id"], :name => "index_publishers_on_asset_id"

  create_table "relation_types", :force => true do |t|
    t.text    "name",    :limit => 16777215,                    :null => false
    t.boolean "visible",                     :default => false, :null => false
  end

  create_table "relations", :force => true do |t|
    t.integer  "asset_id",            :limit => 11
    t.integer  "relation_type_id",    :limit => 11
    t.string   "relation_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relations", ["asset_id"], :name => "index_relations_on_asset_id"
  add_index "relations", ["relation_identifier"], :name => "index_relations_on_relation_identifier"

  create_table "rights_summaries", :force => true do |t|
    t.integer  "asset_id",       :limit => 11
    t.text     "rights_summary", :limit => 16777215, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rights_summaries", ["asset_id"], :name => "index_rights_summaries_on_asset_id"

  create_table "subjects", :force => true do |t|
    t.text     "subject",                              :null => false
    t.text     "subject_authority"
    t.boolean  "visible",           :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "title_type_categories", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "title_types", :force => true do |t|
    t.string  "name",                                         :null => false
    t.integer "category_id", :limit => 11
    t.boolean "visible",                   :default => false, :null => false
  end

  add_index "title_types", ["name"], :name => "index_title_types_on_name"

  create_table "titles", :force => true do |t|
    t.integer  "asset_id",      :limit => 11
    t.text     "title",         :limit => 16777215, :null => false
    t.integer  "title_type_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.boolean  "is_admin",                                 :default => false, :null => false
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
