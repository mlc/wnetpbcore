class InstantiationRelation < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :instantiation
  belongs_to :relation_type
  stampable

  accepts_nested_attributes_for :relation_type

  xml_string "instantiationRelationType", :relation_type
  xml_string "instantiationRelationIdentifier", :instantiation_relation_identifier

  def relation_type_name
    relation_type.try(:name)
  end
  
  def relation_type_name=(name)
    self.relation_type = RelationType.find_by_name(name) if name.present?
  end
  
  def to_s
    "#{instantiation_relation_identifier}"
  end
end
