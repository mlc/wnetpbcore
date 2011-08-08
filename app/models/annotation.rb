class Annotation < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :instantiation
  
  xml_text_field "annotation"
  xml_attributes "annotationType", "ref"
end
