class Asset < ActiveRecord::Base
  before_create :generate_uuid
  before_save :update_asset_terms

  attr_protected :uuid, :asset_terms, :asset_terms_id
  
  include PbcoreXmlElement

  ALL_INCLUDES = [{:identifiers => [:identifier_source]},
    {:titles => [:title_type]}, :subjects, {:descriptions => [:description_type]},
    :genres, {:relations => [:relation_type]}, :coverages, :audience_levels,
    :audience_ratings, {:creators => [:creator_role]},
    {:contributors => [:contributor_role]}, {:publishers => [:publisher_role]},
    :rights_summaries, :extensions,
    {:instantiations => [{:format_ids => :format_identifier_source}, :format,
      :format_media_type, :format_generation, :format_color,
      {:essence_tracks => [:essence_track_type, :essence_track_identifier_source]},
      :date_availables, :annotations]}
    ]
  has_many :identifiers, :dependent => :destroy, :attributes => true
  has_many :titles, :dependent => :destroy, :attributes => true
  has_and_belongs_to_many :subjects
  has_many :descriptions, :dependent => :destroy, :attributes => true
  has_and_belongs_to_many :genres
  has_many :relations, :dependent => :destroy, :attributes => true
  has_many :coverages, :dependent => :destroy, :attributes => true
  has_and_belongs_to_many :audience_levels
  has_and_belongs_to_many :audience_ratings
  has_many :creators, :dependent => :destroy, :attributes => true
  has_many :contributors, :dependent => :destroy, :attributes => true
  has_many :publishers, :dependent => :destroy, :attributes => true
  has_many :rights_summaries, :dependent => :destroy, :attributes => true
  has_many :instantiations, :dependent => :destroy
  has_many :extensions, :dependent => :destroy, :attributes => true
  has_one :asset_terms, :dependent => :destroy

  validates_size_of :identifiers, :minimum => 1, :message => "must have at least one entry"
  validates_size_of :titles, :minimum => 1, :message => "must have at least one entry"
  
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
      "xsi:schemaLocation" => "http://www.pbcore.org/PBCore/PBCoreNamespace.html http://www.pbcore.org/PBCore/PBCoreXSD_Ver_1-2-1.xsd" do
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
  
  def title
    titles.map{|t| t.title}.join("; ")
  end

  def identifier
    result = identifiers.select{|id| id.identifier_source.show_in_index?}
    (result.empty? ? identifiers : result).map{|id| id.identifier}.join(" / ")
  end

  def update_asset_terms
    self.asset_terms ||= AssetTerms.new
    asset_terms.identifier = (
      identifiers.map{|a| [a.identifier, a.identifier_source.name]} +
      instantiations.map{|a| a.format_ids.map{|b| b.format_identifier}}
    ).flatten.join(' ')
    asset_terms.title = titles.map{|a| [a.title_type.nil? ? [] : a.title_type.name, a.title]}.flatten.join(' ')
    asset_terms.subject = subjects.map{|a| a.subject}.join(' ')
    asset_terms.description = descriptions.map{|a| a.description}.join(' ')
    asset_terms.genre = genres.map{|a| a.name}.join(' ')
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
      instantiations.map{|a| [a.date_created, a.date_issued]+a.date_availables.map{|b| [b.date_available_start, b.date_available_end]}}
    ).flatten.join(' ')
    asset_terms.format = instantiations.map{|a| a.format.nil? ? '' : a.format.name}.join(' ')
  end

  def self.dedupe
    dedupe_field(:titles, :title, :title_type_id)
    dedupe_field(:identifiers, :identifier, :identifier_source_id)
    dedupe_field(:descriptions, :description, :description_type_id)
    dedupe_field(:creators, :creator, :creator_role_id)
    dedupe_field(:contributors, :contributor, :contributor_role_id)
    dedupe_field(:publishers, :publisher, :publisher_role_id)
    dedupe_trivial_field(:assets_subjects, :asset_id, :subject_id)
    dedupe_trivial_field(:assets_genres, :asset_id, :genre_id)
  end
  
  protected
  def generate_uuid
    self.uuid = UUID.random_create.to_s unless (self.uuid && !self.uuid.empty?)
  end

  def self.dedupe_field(table, *fields)
    connection.execute("create temporary table tmp_#{table}_ids select distinct b.id from #{table} a, #{table} b where " + fields.map{|f| "a.#{f} = b.#{f}"}.join(" and ") + " and a.asset_id = b.asset_id and a.id < b.id")
    connection.execute("delete from #{table} where id in (select * from tmp_#{table}_ids)")
    connection.execute("drop temporary table tmp_#{table}_ids")
  end

  def self.dedupe_trivial_field(table, *fields)
    fieldlist = fields.join(", ")
    connection.execute("CREATE TEMPORARY TABLE tmp_#{table}_t1 SELECT *, COUNT(*) AS c FROM #{table} GROUP BY #{fieldlist}")
    connection.execute("CREATE TEMPORARY TABLE tmp_#{table}_t2 SELECT #{fieldlist} FROM tmp_#{table}_t1 WHERE c > 1")
    connection.execute("DELETE FROM #{table} WHERE (#{fieldlist}) IN (SELECT * FROM tmp_#{table}_t2)")
    connection.execute("INSERT INTO #{table} (SELECT * FROM tmp_#{table}_t2)")
    connection.execute("DROP TEMPORARY TABLE tmp_#{table}_t1")
    connection.execute("DROP TEMPORARY TABLE tmp_#{table}_t2")
  end
end
