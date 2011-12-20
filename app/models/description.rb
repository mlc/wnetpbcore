class Description < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :description_type
  stampable
  
  accepts_nested_attributes_for :description_type
  
  xml_text_field :description
  xml_attributes "descriptionType", "descriptionTypeSource", "descriptionTypeRef", "descriptionTypeAnnotation", "segmentType", "segmentTypeSource", "segmentTypeRef", "segmentTypeAnnotation", "startTime", "endTime", "timeAnnotation", "annotation"

  validates_length_of :description, :minimum => 1
  
  def description_type_name
    description_type.try(:name)
  end
  
  def description_type_name=(name)
    self.description_type = DescriptionType.find_by_name(name) if name.present?
  end
end
