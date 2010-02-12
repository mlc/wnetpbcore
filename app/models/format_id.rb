class FormatId < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :instantiation
  belongs_to :format_identifier_source

  validates_length_of :format_identifier, :minimum => 1
  
  xml_string "formatIdentifier"
  xml_picklist "formatIdentifierSource"
  def validate
    super
    unless doing_xml? || format_identifier_source.nil? || format_identifier_source.regex.nil? ||
        Regexp.new(format_identifier_source.regex).match(format_identifier)
      self.errors.add("format_identifier", "does not match the rules for the selected identifier source")
    end
  end

  def online?
    format_identifier_source_id == FormatIdentifierSource::OUR_ONLINE_SOURCE.id
  end

  def thumbnail?
    format_identifier_source_id == FormatIdentifierSource::OUR_THUMBNAIL_SOURCE.id
  end
end
