class Contributor < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :contributor_role
  stampable

  xml_string "contributor", nil, "affiliation", "ref", "annotation", "startTime", "endTime", "timeAnnotation"
  xml_string "contributorRole", nil, {"portrayal" => :role_portrayal}, {"source" => :role_source}, {"ref" => :role_ref}, {"version" => :role_version}, {"annotation" => :role_annotation}
  
  validates_presence_of :contributor
  validates_length_of :contributor, :minimum => 1

  def to_s
    contributor_role.nil? ? contributor : "#{contributor_role.name}: #{contributor}"
  end
end
