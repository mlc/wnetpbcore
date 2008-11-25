class FormatId < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :instantiation
  belongs_to :format_identifier_source

  validates_length_of :format_identifier, :minimum => 1
  
  xml_string "formatIdentifier"
  xml_picklist "formatIdentifierSource"
end
