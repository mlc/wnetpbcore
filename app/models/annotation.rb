class Annotation < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :container, :polymorphic => true
  
  xml_text_field "annotation"
  xml_attributes "annotationType", "ref"
end
