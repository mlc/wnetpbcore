class Contributor < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :contributor_role
  stampable

  accepts_nested_attributes_for :contributor_role

  xml_string "contributor", nil, "affiliation", "ref", "source", "annotation", "startTime", "endTime", "timeAnnotation"
  xml_string "contributorRole", nil
  
  validates_presence_of :contributor
  validates_length_of :contributor, :minimum => 1
  
  def contributor_role_name
    contributor_role.try(:name)
  end
  
  def contributor_role_name=(name)
    self.contributor_role = ContributorRole.find_by_name(name) if name.present?
  end
  
  def to_s
    contributor_role.nil? ? contributor : "#{contributor_role.name}: #{contributor}"
  end
end
