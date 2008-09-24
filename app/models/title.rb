class Title < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :title_type
  belongs_to :asset
  xml_string "title", :title
  xml_picklist "titleType", :title_type, TitleType
end
