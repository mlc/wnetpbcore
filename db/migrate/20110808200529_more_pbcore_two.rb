class MorePbcoreTwo < ActiveRecord::Migration
  CONTRIBUTOR_LIKE_TABLES = [:contributors, :creators, :publishers]
  CONTRIBUTOR_LIKE_FIELDS = [:affiliation, :ref, :annotation, :start_time, :end_time, :time_annotation, :role_source, :role_ref, :role_version, :role_annotation]

  def self.up
    CONTRIBUTOR_LIKE_TABLES.each do |table|
      flds = table == :contributors ? CONTRIBUTOR_LIKE_FIELDS + [:role_portrayal] : CONTRIBUTOR_LIKE_FIELDS
      flds.each do |field|
        add_column table, field, :text, :default => nil, :null => true
      end
    end
  end

  def self.down
    CONTRIBUTOR_LIKE_TABLES.each do |table|
      CONTRIBUTOR_LIKE_FIELDS.each do |field|
        remove_column table, col
      end
    end
  end
end
