class AddRightsSummaryRefAndSource < ActiveRecord::Migration
  def self.up
    add_column :rights_summaries, :source, :text
    add_column :rights_summaries, :ref, :text
  end

  def self.down
    remove_column :rights_summaries, :ref
    remove_column :rights_summaries, :source
  end
end