class Instantiation < ActiveRecord::Base
  include PbcoreXmlElement
  include ActionView::Helpers::NumberHelper
  
  belongs_to :asset
  has_many :format_ids, :dependent => :destroy, :attributes => true
  belongs_to :format
  belongs_to :format_media_type
  belongs_to :format_generation
  belongs_to :format_color
  has_many :essence_tracks, :dependent => :destroy, :attributes => true
  has_many :date_availables, :dependent => :destroy, :attributes => true
  has_many :annotations, :dependent => :destroy, :attributes => true
  has_many :borrowings, :dependent => :destroy
  
  attr_protected :asset, :asset_id, :uuid

  validates_presence_of :format_location
  validates_size_of :format_ids, :minimum => 1

  before_create :generate_uuid
  
  xml_subelements "pbcoreFormatID", :format_ids
  to_xml_elt do |obj|
    xml = obj._working_xml
    xml.pbcoreFormatID do
      xml.formatIdentifier obj.uuid
      xml.formatIdentifierSource "pbcore XML database UUID"
    end
  end
  xml_string "dateCreated"
  xml_string "dateIssued"
  xml_picklist "formatPhysical", :format, FormatPhysical
  xml_picklist "formatDigital", :format, FormatDigital
  xml_string "formatLocation"
  xml_picklist "formatMediaType"
  xml_picklist "formatGenerations", :format_generation
  xml_string "formatFileSize"
  xml_string "formatTimeStart"
  xml_string "formatDuration"
  xml_string "formatDataRate"
  xml_picklist "formatColors", :format_color, FormatColor
  xml_string "formatTracks"
  xml_string "formatChannelConfiguration"
  xml_string "language"
  xml_string "alternativeModes"
  xml_subelements "pbcoreEssenceTrack", :essence_tracks
  xml_subelements "pbcoreDateAvailable", :date_availables
  xml_subelements "pbcoreAnnotation", :annotations
  
  def identifier
    format_ids.map{|i| i.format_identifier}.join("; ")
  end

  def summary
    result = (format_ids.map{|id| id.format_identifier}.join(" / ") +
      (format.nil? ? '' : " (#{format.name})") +
      " " + date_issued.to_s).strip
    (result.empty? ? "(instantiation)" : result)
  end

  def annotation
     annotations.empty? ? nil : "[#{annotations.map{|ann| ann.annotation}.join("; ")}]"
  end

  def borrowed?
    borrowings.any?{|b| b.active?}
  end

  def current_borrowing
    borrowings.find(:first, :conditions => "returned IS NULL")
  end

  def pretty_file_size
    if format_file_size =~ /^\d+$/
      number_to_human_size(format_file_size)
    else
      format_file_size
    end
  end

  # TODO: it would be nice to make this configurable somehow for non-WNET installs
  def availability
    case self.format_location
    when /^archive/i, /^wnet/i, /^\//, /^[a-z]{1,8}:\/\//
      2
    when /^offsite/i, /^tbd/i
      1
    else
      0
    end
  end

  protected
  def generate_uuid
    self.uuid = UUID.random_create.to_s unless (self.uuid && !self.uuid.empty?)
  end
end
