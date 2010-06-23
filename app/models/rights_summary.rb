class RightsSummary < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  stampable

  xml_string "rightsSummary"

  validates_length_of :rights_summary, :minimum => 1
end
