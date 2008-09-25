class Coverage < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  xml_string "coverage"
  xml_string "coverageType"
end
