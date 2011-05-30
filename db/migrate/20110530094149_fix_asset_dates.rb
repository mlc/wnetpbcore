class FixAssetDates < ActiveRecord::Migration
  def self.up
    change_column :asset_dates, :asset_date, :text
  end

  def self.down
    change_column :asset_dates, :asset_date, :datetime
  end
end
