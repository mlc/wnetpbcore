class Relation < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :relation_type
  stampable

  accepts_nested_attributes_for :relation_type

  xml_string "pbcoreRelationType", :relation_type
  xml_string "pbcoreRelationIdentifier", :relation_identifier, "source", "ref", "annotation"

  def relation_type_name
    relation_type.try(:name)
  end
  
  def relation_type_name=(name)
    self.relation_type = RelationType.find_by_name(name) if name.present?
  end
  
  def to_s
    "#{relation_identifier}"
  end
end
