class Asset < ActiveRecord::Base
  include PbcoreXmlElement
  has_many :identifiers, :dependent => :destroy
  has_many :titles, :dependent => :destroy
  has_many :subjects
  has_many :descriptions
  has_many :genres
  has_many :relations
  has_many :coverages
  has_and_belongs_to_many :audience_levels
  has_and_belongs_to_many :audience_ratings
  has_many :creators
  has_many :contributors
  has_many :publishers
  has_many :rights_summaries
  has_many :instantiations
  has_many :extensions
  
  xml_subelements "pbcoreIdentifier", :identifiers
  xml_subelements "pbcoreTitle", :titles
  xml_subelements "pbcoreSubject", :subjects
  xml_subelements "pbcoreDescription", :descriptions
  xml_subelements "pbcoreGenre", :genres
  xml_subelements "pbcoreRelation", :relations
  xml_subelements "pbcoreCoverage", :coverages
  xml_subelements_picklist "pbcoreAudienceLevel/pbcore:audienceLevel", :audience_levels
  xml_subelements_picklist "pbcoreAudienceRating/pbcore:audienceRating", :audience_ratings
  xml_subelements "pbcoreCreator", :creators
  xml_subelements "pbcoreContributor", :contributors
  xml_subelements "pbcorePublisher", :publishers
  xml_subelements "pbcoreRightsSummary", :rights_summaries
  xml_subelements "pbcoreInstantiation", :instantiations
  xml_subelements "pbcoreExtension", :extensions
end
