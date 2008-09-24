class Identifier < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :identifier_source
  xml_string "identifier", :identifier
  xml_picklist "identifierSource", :identifier_source, IdentifierSource
end
