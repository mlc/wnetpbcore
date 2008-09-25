class Publisher < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :publisher_role
  xml_string "publisher"
  xml_picklist "publisherRole", :publisher_role, PublisherRole
end
