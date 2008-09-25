class Annotation < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :instantiation
  
  xml_string "annotation"
end
