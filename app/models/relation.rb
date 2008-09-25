class Relation < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :relation_type
  xml_picklist "relationType", :relation_type, RelationType
  xml_string "relationIdentifier", :relation_identifier
end
