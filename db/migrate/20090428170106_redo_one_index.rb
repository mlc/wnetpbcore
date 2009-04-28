class RedoOneIndex < ActiveRecord::Migration
  def self.up
    remove_index :identifiers, [:identifier, :identifier_source_id]
    add_index :identifiers, [:identifier_source_id, :identifier]

    change_column :format_ids, :format_identifier, :string, :null => false
    add_index :format_ids, [:format_identifier_source_id, :format_identifier], :name => "by_source_and_identifier"
  end

  def self.down
    remove_index :identifiers, [:identifier_source_id, :identifier]
    add_index :identifiers, [:identifier, :identifier_source_id]

    remove_index :format_ids, :name => "by_source_and_identifier"
    change_column :format_ids, :format_identifier, :text, :null => false
  end
end
