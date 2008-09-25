class Creator < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :creator_role
  xml_string "creator"
  xml_picklist "creatorRole", :creator_role, CreatorRole
end
