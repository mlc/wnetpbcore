class Title < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :title_type
  belongs_to :asset
  stampable

  xml_text_field :title
  xml_attributes "titleType"
end
