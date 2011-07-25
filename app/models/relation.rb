class Relation < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :relation_type
  stampable

  xml_string "pbcoreRelationType", :relation_type
  xml_string "pbcoreRelationIdentifier", :relation_identifier, "source", "ref", "annotation"
  
  def to_s
    "#{relation_type.name}: #{relation_identifier}"
  end
end
