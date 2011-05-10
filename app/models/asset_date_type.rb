class AssetDateType < ActiveRecord::Base
  include Picklist
  has_many :asset_dates
  quick_column :name
  
  def safe_to_delete?
    asset_dates.size == 0
  end
end
