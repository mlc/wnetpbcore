class InstantiationDate < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :instantiation
  belongs_to :instantiation_date_type
  stampable

  xml_text_field :date
  xml_attributes "dateType" => :instantiation_date_type
end
