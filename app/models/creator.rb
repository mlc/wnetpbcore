class Creator < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :creator_role
  stampable

  xml_string "creator"
  xml_picklist "creatorRole", :creator_role, CreatorRole
  
  def to_s
    creator_role.nil? ? creator : "#{creator_role.name}: #{creator}"
  end
end
