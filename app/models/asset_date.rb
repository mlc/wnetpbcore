class AssetDate < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :asset_date_type
  stampable

  xml_text_field :asset_date
  xml_attributes "dateType" => :asset_date_type
end
