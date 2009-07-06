class Publisher < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :publisher_role
  xml_string "publisher"
  xml_picklist "publisherRole", :publisher_role, PublisherRole

  validates_length_of :publisher, :minimum => 1

  def to_s
    publisher_role.nil? ? publisher : "#{publisher_role.name}: #{publisher}"
  end
end
