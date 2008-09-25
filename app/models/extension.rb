class Extension < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset

  xml_string "extension"
  xml_string "extensionAuthorityUsed"
end
