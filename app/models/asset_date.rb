class AssetDate < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :asset_date_type
  stampable

  xml_string "assetDate"
  xml_picklist "assetDateType", :asset_date_type, AssetDateType
end
