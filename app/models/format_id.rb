class FormatId < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :instantiation

  validates_length_of :format_identifier, :minimum => 1
  
  xml_string "formatIdentifier"
  xml_string "formatIdentifierSource"
end
