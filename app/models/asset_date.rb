class AssetDate < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :asset_date_type
  stampable

  xml_attribute "assetDateType", "dateType"
  xml_picklist "assetDateType", :asset_date_type, AssetDateType
  xml_string "assetDate"
end
