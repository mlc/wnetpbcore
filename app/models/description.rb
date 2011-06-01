class Description < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :description_type
  stampable
  
  xml_string "description"
  xml_string "descriptionType"

  validates_length_of :description, :minimum => 1
end
