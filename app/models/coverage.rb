class Coverage < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  stampable

  xml_string "coverage"
  xml_string "coverageType"

  validates_length_of :coverage, :minimum => 1
  validates_length_of :coverage_type, :minimum => 1

end
