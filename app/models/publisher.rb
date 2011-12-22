class Publisher < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :publisher_role
  stampable

  accepts_nested_attributes_for :publisher_role

  xml_string "publisher", nil, "affiliation", "ref", "source", "annotation", "startTime", "endTime", "timeAnnotation"
  xml_string "publisherRole", nil

  validates_length_of :publisher, :minimum => 1

  def publisher_role_name
    publisher_role.try(:name)
  end
  
  def publisher_role_name=(name)
    self.publisher_role = PublisherRole.find_by_name(name) if name.present?
  end

  def to_s
    publisher_role.nil? ? publisher : "#{publisher_role.name}: #{publisher}"
  end
end
