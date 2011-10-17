class AddRefToSubject < ActiveRecord::Migration
  def self.up
    add_column :subjects, :ref, :string
  end

  def self.down
    remove_column :subjects, :ref
  end
end