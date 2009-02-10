class AddRegexToIdentifierTypes < ActiveRecord::Migration
  def self.up
    add_column :identifier_sources, :regex, :string, :null => true
    add_column :format_identifier_sources, :regex, :string, :null => true
  end

  def self.down
    remove_column :identifier_sources, :regex
    remove_column :format_identifier_sources, :regex
  end
end
