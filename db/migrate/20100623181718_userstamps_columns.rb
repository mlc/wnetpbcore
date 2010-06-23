class UserstampsColumns < ActiveRecord::Migration
  TABLES = [ :assets, :contributors, :coverages, :creators,
             :descriptions, :extension_names, :format_ids, :genres,
             :identifier_sources, :identifiers, :instantiations,
             :publishers, :relations, :rights_summaries, :subjects,
             :titles, :users ]

  def self.up
    TABLES.each do |table|
      add_column table, :creator_id, :integer
      add_column table, :updater_id, :integer
    end
  end

  def self.down
    TABLES.each do |table|
      remove_column table, :creator_id, :integer
      remove_column table, :updater_id, :integer
    end
  end
end
