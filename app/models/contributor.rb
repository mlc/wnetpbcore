class Contributor < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :contributor_role
  xml_string "contributor"
  xml_picklist "contributorRole", :contributor_role, ContributorRole

  def to_s
    "#{contributor_role.name}: #{contributor}"
  end
end
