class Relation < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :relation_type
  stampable

  xml_string "relationType"
  xml_string "relationIdentifier", :relation_identifier
  
  def to_s
    "#{relation_type.name}: #{relation_identifier}"
  end
end
