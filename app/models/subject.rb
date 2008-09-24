class Subject < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  xml_string "subject", :subject
  xml_string "subjectAuthorityUsed", :subject_authority
end
