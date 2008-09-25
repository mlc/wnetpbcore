class DateAvailable < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :instantiation
  
  xml_string "dateAvailableStart"
  xml_string "dateAvailableEnd"
end
