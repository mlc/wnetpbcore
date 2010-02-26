class EssenceTrack < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :instantiation
  belongs_to :essence_track_type
  belongs_to :essence_track_identifier_source

  DISPLAY_FIELDS = ["Identifier", "Standard", "Encoding", "Data Rate", "Time Start", "Duration", "Bit Depth", "Sampling Rate", "Frame Size", "Aspect Ratio", "Frame Rate", "Language", "Annotation"].map{|f| [f, ("essence_track_" + f.gsub(' ', '').underscore).to_sym]}.freeze
  
  xml_picklist "essenceTrackType"
  xml_string "essenceTrackIdentifier"
  xml_picklist "essenceTrackIdentifierSource"
  xml_string "essenceTrackStandard"
  xml_string "essenceTrackEncoding"
  xml_string "essenceTrackDataRate"
  xml_string "essenceTrackTimeStart"
  xml_string "essenceTrackDuration"
  xml_string "essenceTrackBitDepth"
  xml_string "essenceTrackSamplingRate"
  xml_string "essenceTrackFrameSize"
  xml_string "essenceTrackAspectRatio"
  xml_string "essenceTrackFrameRate"
  xml_string "essenceTrackLanguage"
  xml_string "essenceTrackAnnotation"
end
