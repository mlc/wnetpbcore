class Publisher < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :publisher_role
  stampable

  xml_string "publisher", nil, "affiliation", "ref", "annotation", "startTime", "endTime", "timeAnnotation"
  xml_string "publisherRole", nil, {"source" => :role_source}, {"ref" => :role_ref}, {"version" => :role_version}, {"annotation" => :role_annotation}

  validates_length_of :publisher, :minimum => 1

  def to_s
    publisher_role.nil? ? publisher : "#{publisher_role.name}: #{publisher}"
  end
end
