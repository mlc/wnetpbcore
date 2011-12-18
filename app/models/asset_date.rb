class AssetDate < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :asset_date_type
  stampable

  accepts_nested_attributes_for :asset_date_type

  xml_text_field :asset_date
  xml_attributes "dateType" => :asset_date_type
  
  def asset_date_type_name
    asset_date_type.try(:name)
  end
  
  def asset_date_type_name=(name)
    self.asset_date_type = AssetDateType.find_by_name(name) if name.present?
  end
  
end
