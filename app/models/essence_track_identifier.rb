class EssenceTrackIdentifier < ActiveRecord::Base
  include PbcoreXmlElement
  
  belongs_to :essence_track
  belongs_to :essence_track_identifier_source
  #stampable

  accepts_nested_attributes_for :essence_track_identifier_source

  xml_text_field :identifier
  xml_attributes({"source" => :essence_track_identifier_source})
  
  validates_length_of :identifier, :minimum => 1
  validates_presence_of :essence_track_identifier_source
  
  def essence_track_identifier_source_name
    essence_track_identifier_source.try(:name)
  end
  
  def essence_track_identifier_source_name=(name)
    self.essence_track_identifier_source = EssenceTrackIdentifierSource.find_by_name(name) if name.present?
  end

end
