class Instantiation < ActiveRecord::Base
  include PbcoreXmlElement
  include ActionView::Helpers::NumberHelper

  before_create :generate_uuid
  after_destroy :delete_files

  attr_protected :asset, :asset_id, :uuid
  
  belongs_to :asset
  belongs_to :format
  belongs_to :instantiation_media_type
  belongs_to :instantiation_generation
  belongs_to :instantiation_color

  has_many :format_ids,               :dependent => :destroy
  has_many :instantiation_dates,      :dependent => :destroy
  has_many :instantiation_dimensions, :dependent => :destroy
  has_many :essence_tracks,           :dependent => :destroy
  has_many :annotations,              :dependent => :destroy
  has_many :borrowings,               :dependent => :destroy

  stampable

  accepts_nested_attributes_for :format_ids,               :allow_destroy => true
  accepts_nested_attributes_for :instantiation_dates,      :allow_destroy => true
  accepts_nested_attributes_for :instantiation_dimensions, :allow_destroy => true
  accepts_nested_attributes_for :essence_tracks,           :allow_destroy => true
  accepts_nested_attributes_for :annotations,              :allow_destroy => true

  validates_presence_of :format_location
  validates_size_of :format_ids, :minimum => 1

  xml_attributes "startTime", "endTime", "timeAnnotation"
  xml_subelements "instantiationIdentifier", :format_ids
  to_xml_elt do |obj|
    xml = obj._working_xml
    fid = XML::Node.new("instantiationIdentifier", obj.uuid)
    fid["source"] = "pbcore XML database UUID"
    xml << fid
  end
  xml_subelements "instantiationDate", :instantiation_dates
  xml_subelements "instantiationDimensions", :instantiation_dimensions
  from_xml_elt do |record|
    elt = record._working_xml.find_first("pbcore:instantiationPhysical|pbcore:instantiationDigital", PbcoreXmlElement::PBCORE_NAMESPACE)
    if elt && elt.content
      klass = elt.name.sub(/^instantiation/, "Format").constantize
      record.format = klass.find_or_create_by_name(elt.content)
    end
  end
  to_xml_elt do |record|
    if record.format
      eltname = record.format.class.to_s.sub(/^Format/, "instantiation")
      record._working_xml << XML::Node.new(eltname, record.format.name)
    end
  end
  xml_string "instantiationLocation", :format_location
  xml_string "instantiationMediaType", :instantiation_media_type
  xml_string "instantiationGenerations", :instantiation_generation
  xml_string "instantiationFileSize", :format_file_size
  xml_string "instantiationTimeStart", :format_time_start
  xml_string "instantiationDuration", :format_duration
  xml_string "instantiationDataRate", :format_data_rate
  xml_string "instantiationColors", :instantiation_color
  xml_string "instantiationTracks", :format_tracks
  xml_string "instantiationChannelConfiguration", :format_channel_configuration
  xml_string "instantiationLanguage", :language
  xml_string "instantiationAlternativeModes", :alternative_modes
  xml_subelements "pbcoreEssenceTrack", :essence_tracks
  xml_subelements "instantiationAnnotation", :annotations
  
  def format_type
    format.try(:type)
  end
  
  def format_type=(format)
    # do nothing with this
  end
  
  def format_name
    format.try(:name)
  end
  
  def format_name=(name)
    self.format = Format.find_by_name(name) if name.present?
  end
  
  def identifier
    format_ids.map{|i| i.format_identifier}.join("; ")
  end

  def summary
    result = (format_ids.map{|id| id.format_identifier}.join(" / ") +
      (format.nil? ? '' : " (#{format.name})")).strip
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
    template_attrs = template.attributes.reject{|k,v| ["asset_id", "template_name", "id", "uuid"].include?(k)}
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
    doc = XML::Document.new
    root = XML::Node.new("PBCoreDescriptionDocument")
    PbcoreXmlElement::Util.set_pbcore_ns(root)
    doc.root = root
    build_xml(root)
    doc.to_s(:indent => true)
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
