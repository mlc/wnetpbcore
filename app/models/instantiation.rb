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
  stampable
  
  attr_protected :asset, :asset_id, :uuid

  validates_presence_of :format_location
  validates_size_of :format_ids, :minimum => 1

  before_create :generate_uuid
  after_destroy :delete_files
  
  xml_subelements "pbcoreFormatID", :format_ids
  to_xml_elt do |obj|
    xml = obj._working_xml
    fid = XML::Node.new("pbcoreFormatID")
    xml << fid
    fid << XML::Node.new("formatIdentifier", obj.uuid)
    fid << XML::Node.new("formatIdentifierSource", "pbcore XML database UUID")
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
    when /^archive/i, /^wnet/i, /^\//, /^[a-z]{1,8}:\/\//, /^job[0-9]{4}/
      2
    when /^offsite/i, /^tbd/i
      1
    else
      0
    end
  end

  def online?
    format_ids.any?(&:online?)
  end

  def thumbnail?
    format_ids.any?(&:thumbnail?)
  end

  def self.templates(options = nil)
    opts = options || {:select => "id, template_name"}
    inst = Instantiation.all({:conditions => "template_name IS NOT NULL", :order => "template_name ASC"}.merge(opts))
    options ? inst : inst.map{|i| [i.id, i.template_name]}
  end

  def self.new_from_template(template_id, asset = nil)
    template = Instantiation.find(template_id, :include => [:essence_tracks, :annotations])
    template_attrs = template.attributes.reject{|k,v| ["asset_id", "template_name", "date_created", "date_issued", "id", "uuid"].include?(k)}
    newone = Instantiation.new(template_attrs)
    newone.asset = asset
    template.essence_tracks.each do |et|
      newone.essence_tracks << EssenceTrack.new(et.attributes.reject{|k,v| ["instantiation_id", "id", "essence_track_duration"].include?(k)})
    end
    template.annotations.each do |an|
      newone.annotations << Annotation.new(an.attributes.reject{|k,v| ["instantiation_id", "id"].include?(k)})
    end

    newone
  end

  def to_xml
    builder = Builder::XmlMarkup.new(:indent => 2)
    builder.instruct!
    builder.pbcoreInstantiation "xmlns" => "http://www.pbcore.org/PBCore/PBCoreNamespace.html" do
      build_xml(builder)
    end
  end

  protected
  def generate_uuid
    self.uuid = UUID.random_create.to_s unless (self.uuid && !self.uuid.empty?)
  end

  def delete_files
    if online?
      AWS::S3::S3Object.delete(self.format_location, S3SwfUpload::S3Config.bucket)
    elsif thumbnail?
      ["thumb", "original", "preview"].each do |size|
        AWS::S3::S3Object.delete("#{self.format_location}/#{size}", S3SwfUpload::S3Config.bucket)
      end
    end
  end
end
