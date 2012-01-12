class AddIndexForInstantionDates < ActiveRecord::Migration
  def self.up
    add_index :instantiation_dates, :instantiation_id
  end

  def self.down
    remove_index :instantiation_dates, :instantiation_id
  end
end