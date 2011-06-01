class Title < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :title_type
  belongs_to :asset
  stampable

  xml_string "title", :title
  xml_string "titleType"
end
