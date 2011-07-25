class Description < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :description_type
  stampable
  
  xml_text_field :description
  xml_attributes "descriptionType", "descriptionTypeSource", "descriptionTypeRef", "descriptionTypeAnnotation", "segmentType", "segmentTypeSource", "segmentTypeRef", "segmentTypeAnnotation", "startTime", "endTime", "timeAnnotation", "annotation"

  validates_length_of :description, :minimum => 1
end
