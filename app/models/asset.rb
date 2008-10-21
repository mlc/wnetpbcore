class Asset < ActiveRecord::Base
  before_create :generate_uuid
  
  include PbcoreXmlElement
  ALL_INCLUDES = [:identifiers, :titles, :subjects, :descriptions, :genres,
    :relations, :coverages, :audience_levels, :audience_ratings, :creators,
    :contributors, :publishers, :rights_summaries, :instantiations, :extensions
    ]
  has_many :identifiers, :dependent => :destroy
  has_many :titles, :dependent => :destroy
  has_many :subjects, :dependent => :destroy
  has_many :descriptions, :dependent => :destroy
  has_many :genres, :dependent => :destroy
  has_many :relations, :dependent => :destroy
  has_many :coverages, :dependent => :destroy
  has_and_belongs_to_many :audience_levels
  has_and_belongs_to_many :audience_ratings
  has_many :creators, :dependent => :destroy
  has_many :contributors, :dependent => :destroy
  has_many :publishers, :dependent => :destroy
  has_many :rights_summaries, :dependent => :destroy
  has_many :instantiations, :dependent => :destroy
  has_many :extensions, :dependent => :destroy
  
  define_index do
    indexes [identifiers.identifier], :as => :identifier
    indexes [titles.title], :as => :title
    indexes [subjects.subject], :as => :subject
    indexes [descriptions.description], :as => :description
    indexes [genres.genre], :as => :genre
    indexes [relations.relation_identifier], :as => :relation
    indexes [coverages.coverage], :as => :coverage
    indexes [audience_levels.name], :as => :audience_level
    indexes [audience_ratings.name], :as => :audience_rating
    indexes [creators.creator], :as => :creator
    indexes [contributors.contributor], :as => :contributors
    indexes [publishers.publisher], :as => :publishers
    indexes [rights_summaries.rights_summary], :as => :rights
    indexes [extensions.extension_authority_used, extensions.extension], :as => :extension
    has :updated_at
    has :created_at
    
    set_property :delta => true
  end
  
  xml_subelements "pbcoreIdentifier", :identifiers
  to_xml_elt do |obj|
    xml = obj._working_xml
    xml.pbcoreIdentifier do
      xml.identifier obj.uuid
      xml.identifierSource "pbcore XML database UUID"
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
  
  def destroy_existing
    return nil unless new_record?

    possibility = identifiers.detect{|s| s.identifier_source_id == IdentifierSource::OUR_UUID_SOURCE.id}
    if possibility
      other = Asset.find_by_uuid(possibility.identifier)
      self.identifiers -= [possibility]
      self.uuid = possibility.identifier
      other.destroy if other
    end
  end

  protected
  def generate_uuid
    self.uuid = UUID.random_create.to_s unless (self.uuid && !self.uuid.empty?)
  end
end
