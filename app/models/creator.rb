class Creator < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :creator_role
  stampable

  xml_string "creator", nil, "affiliation", "ref", "annotation", "startTime", "endTime", "timeAnnotation"
  xml_string "creatorRole", nil, {"source" => :role_source}, {"ref" => :role_ref}, {"version" => :role_version}, {"annotation" => :role_annotation}
  
  def to_s
    creator_role.nil? ? creator : "#{creator_role.name}: #{creator}"
  end
end
