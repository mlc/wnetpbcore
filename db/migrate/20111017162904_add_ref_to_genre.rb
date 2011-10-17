class AddRefToGenre < ActiveRecord::Migration
  def self.up
    add_column :genres, :ref, :string
  end

  def self.down
    remove_column :genres, :ref
  end
end