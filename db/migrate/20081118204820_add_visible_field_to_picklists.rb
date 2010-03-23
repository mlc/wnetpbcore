class AddVisibleFieldToPicklists < ActiveRecord::Migration
  TABLES = [ :audience_levels, :audience_ratings, :contributor_roles,
    :creator_roles, :description_types, :format_colors, :format_generations,
    :format_media_types, :formats, :identifier_sources, :publisher_roles,
    :relation_types, :title_types ]

  def self.up
    TABLES.each do |table|
      # default for new records is false but exsiting records should be true
      add_column table, :visible, :boolean, :null => false, :default => false
      table.to_s.camelize.singularize.constantize.update_all("visible = #{quote(true)}")
    end
    # lame.
    execute("UPDATE identifier_sources SET visible=#{quote(false)} WHERE id=1")
  end
  
  def self.down
    TABLES.each do |table|
      remove_column table, :visible
    end
  end
end
