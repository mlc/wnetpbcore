class Asset < ActiveRecord::Base
  include PbcoreXmlElement
  
  before_create :generate_uuid
  after_save :save_version

  attr_protected :uuid
  
  # IMPORTANT: This has to be kept in sync with ANY SCHEMA CHANGES!
  ALL_INCLUDES = [{:identifiers => [:identifier_source]},
                  {:titles => [:title_type]},
                  {:asset_dates => [:asset_date_type]},
                  :subjects, 
                  {:descriptions => [:description_type]},
                  :genres,
                  {:relations => [:relation_type]},
                  :coverages,
                  :audience_levels,
                  :audience_ratings,
                  {:creators => [:creator_role]},
                  {:contributors => [:contributor_role]},
                  {:publishers => [:publisher_role]},
                  :rights_summaries,
                  :annotations,
                  :extensions,
                  {:instantiations => [{:format_ids => :format_identifier_source},
                                       :format,
                                       {:instantiation_dates => [:instantiation_date_type]},
                                       :instantiation_dimensions,
                                       {:instantiation_relations => [:relation_type]},
                                       :instantiation_media_type,
                                       :instantiation_generations,
                                       :instantiation_color,
                                       :instantiation_rights_summaries,
                                       {:essence_tracks => [:essence_track_type, 
                                                            :annotations,
                                                            {:essence_track_identifiers => :essence_track_identifier_source}]},
                                       :annotations]}
                 ]

  UUID_REGEX = /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/

  # Intellectual Content
  has_many :identifiers,      :dependent => :destroy
  has_many :titles,           :dependent => :destroy
  has_many :asset_dates,      :dependent => :destroy
  has_and_belongs_to_many :subjects
  has_many :descriptions,     :dependent => :destroy
  has_and_belongs_to_many :genres
  has_many :relations,        :dependent => :destroy
  has_many :coverages,        :dependent => :destroy
  has_and_belongs_to_many :audience_levels
  has_and_belongs_to_many :audience_ratings

  # Intellectual Property
  has_many :creators,         :dependent => :destroy
  has_many :contributors,     :dependent => :destroy
  has_many :publishers,       :dependent => :destroy
  has_many :rights_summaries, :dependent => :destroy

  # Instantiations
  has_many :instantiations,   :dependent => :destroy

  # Annotations
  has_many :annotations, :as => :container, :dependent => :destroy

  # Extensions
  has_many :extensions,       :dependent => :destroy

  has_many :versions,         :dependent => :delete_all
  stampable

  accepts_nested_attributes_for :identifiers,      :allow_destroy => true
  accepts_nested_attributes_for :titles,           :allow_destroy => true
  accepts_nested_attributes_for :descriptions,     :allow_destroy => true
  accepts_nested_attributes_for :relations,        :allow_destroy => true
  accepts_nested_attributes_for :coverages,        :allow_destroy => true
  accepts_nested_attributes_for :creators,         :allow_destroy => true
  accepts_nested_attributes_for :contributors,     :allow_destroy => true
  accepts_nested_attributes_for :publishers,       :allow_destroy => true
  accepts_nested_attributes_for :rights_summaries, :allow_destroy => true
  accepts_nested_attributes_for :annotations,      :allow_destroy => true
  accepts_nested_attributes_for :extensions,       :allow_destroy => true
  accepts_nested_attributes_for :asset_dates,      :allow_destroy => true

  validates_size_of :identifiers, :minimum => 1, :message => "must have at least one entry"
  validates_size_of :titles, :minimum => 1, :message => "must have at least one entry"
  
  
  # IMPORTANT: This has to be kept in sync with ANY SCHEMA CHANGES also order
  # matters here.
  # PbcoreXmlElement Declarations
  
  # Intellectual Content
  xml_subelements "pbcoreAssetDate", :asset_dates  
  xml_subelements "pbcoreIdentifier", :identifiers
  to_xml_elt do |obj|
    xml = obj._working_xml
    identif = XML::Node.new("pbcoreIdentifier", obj.uuid)
    identif["source"] = "pbcore XML database UUID"
    xml << identif
  end
  xml_subelements "pbcoreTitle", :titles
  xml_subelements "pbcoreSubject", :subjects
  xml_subelements "pbcoreDescription", :descriptions
  xml_subelements "pbcoreGenre", :genres
  xml_subelements "pbcoreRelation", :relations
  xml_subelements "pbcoreCoverage", :coverages
  xml_subelements_picklist "pbcoreAudienceLevel", "audienceLevel", :audience_levels
  xml_subelements_picklist "pbcoreAudienceRating", "audienceRating", :audience_ratings
  xml_subelements "pbcoreAnnotation", :annotations
  
  # Intellectual Property
  xml_subelements "pbcoreCreator", :creators
  xml_subelements "pbcoreContributor", :contributors
  xml_subelements "pbcorePublisher", :publishers
  xml_subelements "pbcoreRightsSummary", :rights_summaries
  
  # Extensions
  xml_subelements "pbcoreExtension", :extensions
  
  # Instantiation
  xml_subelements "pbcoreInstantiation", :instantiations
  
  # Sunspot/Solr definitions
  searchable do
    text :identifier do
      identifiers.map{|a| "#{a.identifier} #{a.identifier_source.name}"} +
        (instantiations.map{|a| a.format_ids.map(&:format_identifier)}.flatten)
    end
    text(:title, :boost => 1.2) { titles.map(&:title) }
    text(:subject) { subjects.map(&:subject) }
    text(:description) { descriptions.map(&:description) }
    text(:genre) { genres.map(&:name) }
    text(:relation) { relations.map(&:relation_identifier) }
    text(:coverage) { coverages.map(&:coverage) }
    text(:audience_level) { audience_levels.map(&:name) }
    text(:audience_rating) { audience_ratings.map(&:name) }
    text(:creator) { creators.map(&:creator) }
    text(:contributor) { contributors.map(&:contributor) }
    text(:publisher) { publishers.map(&:publisher) }
    text(:rights) { rights_summaries.map(&:rights_summary) }
    text(:extension) { extensions.map{|a| "#{a.extension} #{a.extension_authority_used}"} }
    text(:location) { instantiations.map{|a| a.format_location} }
    text(:annotation) do
      (
       instantiations.map{|a| a.annotations.map{|b| b.annotation}} +
       instantiations.map{|a| a.essence_tracks.map{|b| b.annotation}}
      ).flatten
    end
    text(:date) do
      (
       asset_dates.map(&:asset_date) + 
       instantiations.map{|a| a.instantiation_dates.map{|b| b.date}}
      ).flatten
    end
    text(:format) { instantiations.map{|a| a.format.nil? ? '' : a.format.name} }
    time :created_at
    time :updated_at
    string :uuid
    boolean(:online_asset) { self.online? }
    dynamic_string :facets, :multiple => true do
      PBCore.config['facets'].inject({}) do |hash, facet|
        key = facet[0].to_sym
        value = []
        case facet[1]
        when "map"
          value = send(facet[2].to_sym).map(&facet[3].to_sym)
        when "simple_map"
          value = send(facet[0].downcase.pluralize.to_sym).map(&facet[0].downcase.to_sym)
        when "if_map"
          value = send(facet[2].to_sym).select{|p|
            subelt = p.send(facet[4].to_sym)
            !(subelt.nil?) && ((subelt.respond_to?(:name) ? subelt.name : subelt) == facet[5])
          }.map(&facet[3].to_sym)
        when "format_location"
          value = instantiations.map{|a| a.format_location}.select{|fml| !(fml.index('/') || fml.match(UUID_REGEX))}
        end
        hash.merge(key => value)
      end
    end
  end
  
  # This is used by the new form to do subject adding/removing autocompletion
  # using jquery token input plugin
  attr_reader :subject_tokens
  def subject_tokens=(ids)
    self.subject_ids = ids.split(",")
  end
  
  attr_reader :genre_tokens
  def genre_tokens=(ids)
    self.genre_ids = ids.split(",")
  end
  
  def to_xml
    doc = XML::Document.new
    root = XML::Node.new("pbcoreDescriptionDocument")
    PbcoreXmlElement::Util.set_pbcore_ns(root)
    xsins = XML::Namespace.new(root, "xsi", "http://www.w3.org/2001/XMLSchema-instance")
    schemaloc = XML::Attr.new(root, "schemaLocation", "http://www.pbcore.org/PBCore/PBCoreNamespace.html http://pbcore.org/xsd/pbcore-2.0.xsd")
    schemaloc.namespaces.namespace = xsins
    doc.root = root
    root << XML::Node.new_comment("XML Generated at #{Time.new} by rails pbcore database")
    root << XML::Node.new_comment(created_string) if respond_to?(:created_at)
    root << XML::Node.new_comment(updated_string) if respond_to?(:updated_at)
    build_xml(root)
    doc.to_s
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

  def online?
    instantiations.any?(&:online?)
  end

  def has_thumbnail?
    instantiations.any?(&:thumbnail?)
  end

  def thumbnail
    instantiations.detect(&:thumbnail?)
  end

  # Copies the stuff from a new asset object into us.
  # IMPORTANT: Any changes to models or the schema might affect this code. 
  #            CHECK THIS WHEN THE SCHEMA CHANGES!
  def merge(new_asset)
    [:identifiers, :titles, :descriptions, :relations, :coverages, :creators, :contributors,
      :publishers, :rights_summaries, :instantiations, :extensions, :asset_dates].each do |field|
      current_fields = self.send(field)
      new_fields     = new_asset.send(field)

      current_attrs  = current_fields.map{|o| clean_attributes(o.attributes)}

      # this is O(n²), but hopefully n is small enough that this isn't a huge problem
      new_fields.each do |fields|
        current_fields << fields unless current_attrs.include?(clean_attributes(fields.attributes))
      end
    end
    
    [:genre_ids, :subject_ids, :audience_level_ids, :audience_rating_ids].each do |field|
      self.send("#{field}=".to_sym, self.send(field) | new_asset.send(field))
    end
  end

  def merge_existing
    return nil unless new_record?

    found = nil
    self.identifiers.each do |identifier|
      if identifier.identifier_source.auto_merge && (them = Identifier.find_by_identifier_and_identifier_source_id(identifier.identifier, identifier.identifier_source_id))
        found = Asset.find(them.asset_id, :include => ALL_INCLUDES)
        break
      end
    end

    if found
      found.merge(self)
      found.save
    end

    found
  end

  # IMPORTANT: This needs to be checked when the SCHEMA or MODEL changes!
  def self.full_text_fields
    # there must be a DRY way to ask sunspot for this
    [
     :identifier, :title, :subject, :description, :genre, :relation, :coverage,
     :audience_level, :audience_rating, :creator, :contributor, :publisher,
     :rights, :extension, :location, :annotation, :date, :format
    ]
  end

  # import some XML
  # returns an array. the first elt is an array of UUIDs of successful
  # imports; the second is an array of error messages.
  def self.import_xml(stream_or_string, fn = "input")
    begin
      if (stream_or_string.respond_to?(:read))
        parser = XML::Parser.io(stream_or_string)
      else
        parser = XML::Parser.string(stream_or_string)
      end

      xmldoc = parser.parse
    rescue ex
      return [[], [ex.to_s]]
    end

    docs = xmldoc.find("/pbcore:pbcoreDescriptionDocument|/pbcore:PBCoreDescriptionDocument|/pbcore:pbcoreCollection/pbcore:pbcoreDescriptionDocument", PbcoreXmlElement::PBCORE_NAMESPACE)

    if docs.size == 0
      [[], ["no PBCore Description Documents found"]]
    else
      count = 0
      successes = []
      errors = []

      docs.each do |doc|
        count += 1
        Asset.transaction do
          asset = Asset.from_xml(doc)
          if asset.valid?
            asset.destroy_existing
            asset.save unless asset.merge_existing
            successes << asset.uuid
          else
            errors << "document #{count} of #{fn} is not valid: #{asset.errors.full_messages.join("; ")}"
            raise ActiveRecord::Rollback
          end
        end
      end

      [successes, errors]
    end
  end

  def self.xmlify_import_results(results)
    successes, failures = results
    doc = XML::Document.new
    doc.root = root = XML::Node.new("results")
    successes_node = XML::Node.new("successes")
    root << successes_node
    successes.each do |succ|
      succ_text = block_given? ? yield(succ) : succ
      successes_node << XML::Node.new("success", succ_text)
    end
    failures_node = XML::Node.new("failures")
    root << failures_node
    failures.each do |failure|
      failures_node << XML::Node.new("failure", failure)
    end

    doc.to_s(:indent => false)
  end

  # IMPORTANT: This code needs to be checked when models or the schema
  #            changes.
  def self.dedupe
    dedupe_field(:titles, :title, :title_type_id, :asset_id)
    dedupe_field(:identifiers, :identifier, :identifier_source_id, :asset_id)
    dedupe_field(:descriptions, :description, :description_type_id, :asset_id)
    dedupe_field(:creators, :creator, :creator_role_id, :asset_id)
    dedupe_field(:contributors, :contributor, :contributor_role_id, :asset_id)
    dedupe_field(:publishers, :publisher, :publisher_role_id, :asset_id)
    dedupe_field(:format_ids, :instantiation_id, :format_identifier, :format_identifier_source_id)
    dedupe_field(:annotations, :instantiation_id, :annotation)
    # dedupe_field(:date_availables, :instantiation_id, :date_available_start, :date_available_end)
    dedupe_trivial_field(:assets_subjects, :asset_id, :subject_id)
    dedupe_trivial_field(:assets_genres, :asset_id, :genre_id)
  end

  protected
  
  # Protected Class methods
  def self.dedupe_field(table, *fields)
    connection.execute("create temporary table tmp_#{table}_ids select distinct b.id from #{table} a, #{table} b where " + fields.map{|f| "a.#{f} = b.#{f}"}.join(" and ") + " and a.id < b.id")
    connection.execute("delete from #{table} where id in (select * from tmp_#{table}_ids)")
    $stdout.puts("#{count_by_sql("SELECT COUNT(*) FROM tmp_#{table}_ids")} #{table} deleted")
    connection.execute("drop temporary table tmp_#{table}_ids")
  end

  def self.dedupe_trivial_field(table, *fields)
    fieldlist = fields.join(", ")
    connection.execute("CREATE TEMPORARY TABLE tmp_#{table}_t1 SELECT *, COUNT(*) AS c FROM #{table} GROUP BY #{fieldlist}")
    connection.execute("CREATE TEMPORARY TABLE tmp_#{table}_t2 SELECT #{fieldlist} FROM tmp_#{table}_t1 WHERE c > 1")
    connection.execute("DELETE FROM #{table} WHERE (#{fieldlist}) IN (SELECT * FROM tmp_#{table}_t2)")
    connection.execute("INSERT INTO #{table} (SELECT * FROM tmp_#{table}_t2)")
    $stdout.puts("#{count_by_sql("SELECT COUNT(*) FROM tmp_#{table}_t2")} duplicate #{table} cleaned up")
    connection.execute("DROP TEMPORARY TABLE tmp_#{table}_t1")
    connection.execute("DROP TEMPORARY TABLE tmp_#{table}_t2")
  end

  # Protected Instance methods
  def generate_uuid
    self.uuid = UUID.random_create.to_s unless (self.uuid && !self.uuid.empty?)
  end

  def clean_attributes(hash)
    hash.delete("asset_id")
    hash.delete("id")
    hash.delete("uuid")
    hash.delete("created_at")
    hash.delete("updated_at")
    hash.delete("created_by")
    hash.delete("updated_by")
    hash
  end

  def save_version
    Version.create(:asset => self, :body => self.to_xml)
  end
end
