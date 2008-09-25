class RightsSummary < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  xml_string "rightsSummary"
end
