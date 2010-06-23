class Contributor < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :contributor_role
  stampable

  xml_string "contributor"
  xml_picklist "contributorRole", :contributor_role, ContributorRole
  
  validates_presence_of :contributor
  validates_length_of :contributor, :minimum => 1

  def to_s
    contributor_role.nil? ? contributor : "#{contributor_role.name}: #{contributor}"
  end
end
