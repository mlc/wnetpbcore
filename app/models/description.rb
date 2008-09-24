class Description < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :description_type
  
  xml_string "description", :description
  xml_picklist "descriptionType", :description_type, DescriptionType
end
