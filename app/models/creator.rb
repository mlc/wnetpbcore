class Creator < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :creator_role
  stampable

  accepts_nested_attributes_for :creator_role

  xml_string "creator", nil, "affiliation", "ref", "source", "annotation", "startTime", "endTime", "timeAnnotation"
  xml_string "creatorRole"

  def creator_role_name
    creator_role.try(:name)
  end
  
  def creator_role_name=(name)
    self.creator_role = CreatorRole.find_by_name(name) if name.present?
  end
   
  def to_s
    creator_role.nil? ? creator : "#{creator} (#{creator_role.name})"
  end
end
