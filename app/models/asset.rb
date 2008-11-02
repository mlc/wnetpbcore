class Asset < ActiveRecord::Base
  before_create :generate_uuid
  before_save :update_asset_terms
  
  include PbcoreXmlElement
  ALL_INCLUDES = [:identifiers, :titles, :subjects, :descriptions, :genres,
    :relations, :coverages, :audience_levels, :audience_ratings, :creators,
    :contributors, :publishers, :rights_summaries, :instantiations, :extensions
    ]
  has_many :identifiers, :dependent => :destroy, :attributes => true
  has_many :titles, :dependent => :destroy, :attributes => true
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
  has_one :asset_terms, :dependent => :destroy
  
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
 
  def update_asset_terms
    self.asset_terms ||= AssetTerms.new
    asset_terms.identifier = (
      identifiers.map{|a| [a.identifier, a.identifier_source.name]} +
      instantiations.map{|a| a.format_ids.map{|b| b.format_identifier}}
    ).flatten.join(' ')
    asset_terms.title = titles.map{|a| a.title}.join(' ')
    asset_terms.subject = subjects.map{|a| a.subject}.join(' ')
    asset_terms.description = descriptions.map{|a| a.description}.join(' ')
    asset_terms.genre = genres.map{|a| a.genre}.join(' ')
    asset_terms.relation = relations.map{|a| a.relation_identifier}.join(' ')
    asset_terms.coverage = coverages.map{|a| a.coverage}.join(' ')
    asset_terms.audience_level = audience_levels.map{|a| a.name}.join(' ')
    asset_terms.audience_rating = audience_ratings.map{|a| a.name}.join(' ')
    asset_terms.creator = creators.map{|a| a.creator}.join(' ')
    asset_terms.contributor = contributors.map{|a| a.contributor}.join(' ')
    asset_terms.publisher = publishers.map{|a| a.publisher}.join(' ')
    asset_terms.rights = rights_summaries.map{|a| a.rights_summary}.join(' ')
    asset_terms.extension = extensions.map{|a| "#{a.extension} #{a.extension_authority_used}"}.join(' ')
    asset_terms.location = instantiations.map{|a| a.format_location}.join(' ')
    asset_terms.annotation = (
      instantiations.map{|a| a.annotations.map{|b| b.annotation}} +
      instantiations.map{|a| a.essence_tracks.map{|b| b.essence_track_annotation}}
    ).flatten.join(' ')
    asset_terms.date = (
      instantiations.map{|a| a.date_availables.map{|b| [b.date_available_start, b.date_available_end]}}
    ).flatten.join(' ')
  end
  
  protected
  def generate_uuid
    self.uuid = UUID.random_create.to_s unless (self.uuid && !self.uuid.empty?)
  end
end
