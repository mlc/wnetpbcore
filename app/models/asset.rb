class Asset < ActiveRecord::Base
  include PbcoreXmlElement
  ALL_INCLUDES = [:identifiers, :titles, :subjects, :descriptions, :genres,
    :relations, :coverages, :audience_levels, :audience_ratings, :creators,
    :contributors, :publishers, :rights_summaries, :instantiations, :extensions
    ]
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
  
  define_index do
    indexes [identifiers.identifier], :as => :identifier
    indexes [titles.title], :as => :title
    indexes [subjects.subject], :as => :subject
    indexes [descriptions.description], :as => :description
    indexes [genres.genre], :as => :genre
    indexes [relations.relation_type.name, relations.relation_identifier], :as => :relation
    indexes [coverages.coverage, coverages.coverage_type], :as => :coverage
    indexes [audience_levels.name], :as => :audience_level
    indexes [audience_ratings.name], :as => :audience_rating
    indexes [creators.creator_role.name, creators.creator], :as => :creator
    indexes [contributors.contributor_role.name, contributors.contributor], :as => :contributors
    indexes [publishers.publisher_role.name, publishers.publisher], :as => :publishers
    indexes [rights_summaries.rights_summary], :as => :rights
    indexes [extensions.extension_authority_used, extensions.extension], :as => :extension
    has :updated_at
    has :created_at
  end
  
  xml_subelements "pbcoreIdentifier", :identifiers
  to_xml_elt do |obj|
    xml = obj._working_xml
    xml.pbcoreIdentifier do
      xml.identifier obj.id
      xml.identifierSource "pbcore XML database"
    end
  end
  xml_subelements "pbcoreTitle", :titles
  xml_subelements "pbcoreSubject", :subjects
  xml_subelements "pbcoreDescription", :descriptions
  xml_subelements "pbcoreGenre", :genres
  xml_subelements "pbcoreRelation", :relations
  xml_subelements "pbcoreCoverage", :coverages
  xml_subelements_picklist "pbcoreAudienceLevel", "audienceLevel", :audience_levels
  xml_subelements_picklist "pbcoreAudienceRating", "audienceRating", :audience_ratings
  xml_subelements "pbcoreCreator", :creators
  xml_subelements "pbcoreContributor", :contributors
  xml_subelements "pbcorePublisher", :publishers
  xml_subelements "pbcoreRightsSummary", :rights_summaries
  xml_subelements "pbcoreInstantiation", :instantiations
  xml_subelements "pbcoreExtension", :extensions
  
  def to_xml
    builder = Builder::XmlMarkup.new(:indent => 2)
    builder.instruct!
    builder.PBCoreDescriptionDocument "xmlns" => "http://www.pbcore.org/PBCore/PBCoreNamespace.html",
      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
      "xsi:schemaLocation" => "http://www.pbcore.org/PBCore/PBCoreNamespace.html http://www.pbcore.org/PBCore/PBCoreSchema.xsd" do
      builder.comment! "XML Generated at #{Time.new} by rails pbcore database"
      build_xml(builder)
    end
  end
end
