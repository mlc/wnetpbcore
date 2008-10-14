class Description < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :description_type
  
  xml_string "description"
  xml_picklist "descriptionType", :description_type, DescriptionType

  validates_length_of :description, :minimum => 1
end
