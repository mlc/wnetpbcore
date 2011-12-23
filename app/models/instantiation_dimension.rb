class InstantiationDimension < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :instantiation
  
  xml_text_field :dimension
  xml_attributes "unitsOfMeasure"
end
