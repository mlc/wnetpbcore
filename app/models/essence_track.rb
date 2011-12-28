class EssenceTrack < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :instantiation
  belongs_to :essence_track_type
  belongs_to :essence_track_identifier_source

  DISPLAY_FIELDS = ["Identifier", "Standard", "Encoding", "Data Rate", "Time Start", "Duration", "Bit Depth", "Sampling Rate", "Frame Size", "Aspect Ratio", "Frame Rate", "Language", "Annotation"].map{|f| [f, ("" + f.gsub(' ', '').underscore).to_sym]}.freeze
  
  xml_string "essenceTrackType"
  xml_string "essenceTrackIdentifier", :identifier
  xml_string "essenceTrackIdentifierSource"
  xml_string "essenceTrackStandard", :standard
  xml_string "essenceTrackEncoding", :encoding
  xml_string "essenceTrackDataRate", :data_rate
  xml_string "essenceTrackTimeStart", :time_start
  xml_string "essenceTrackDuration", :duration
  xml_string "essenceTrackBitDepth", :bit_depth
  xml_string "essenceTrackSamplingRate", :sampling_rate, { "unitsOfMeasure" => :sampling_rate_units_of_measure }
  xml_string "essenceTrackFrameSize", :frame_size
  xml_string "essenceTrackAspectRatio", :aspect_ratio
  xml_string "essenceTrackFrameRate", :frame_rate
  xml_string "essenceTrackPlaybackSpeed", :playback_speed, { "unitsOfMeasure" => :playback_speed_units_of_measure }
  xml_string "essenceTrackLanguage", :language
  xml_string "essenceTrackAnnotation", :annotation
  
  
  def language_tokens
    if language.present?
      language.gsub(/;/, ",") 
    else
      ""
    end
  end
  
  def language_tokens=(tokens)
    self.language = tokens.gsub(/,/, ";") if tokens.present?
  end
end
