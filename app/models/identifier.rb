class Identifier < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :identifier_source
  xml_string "identifier", :identifier
  xml_picklist "identifierSource", :identifier_source, IdentifierSource
  
  validates_length_of :identifier, :minimum => 1
  validates_presence_of :identifier_source
end
