class AssetDate < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :asset_date_type
  stampable

  # xml_picklist_attribute "dateType", :asset_date_type
  # xml_picklist "assetDateType", :asset_date_type, AssetDateType
  xml_string "assetDate", :asset_date, {"dateType" => :asset_date_type}
end
