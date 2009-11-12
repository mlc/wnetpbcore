class Subject < ActiveRecord::Base
  include PbcoreXmlElement
  include Picklist

  has_and_belongs_to_many :assets
  quick_column 'CONCAT(subject, " (", COALESCE(subject_authority, ""), ")")'
  xml_string "subject", :subject
  xml_string "subjectAuthorityUsed", :subject_authority

  def name
    subject
  end

  # we use the standard PbcoreXmlElement definition of to_xml, but we have
  # to customize the from_xml direction...
  def self.from_xml(xml)
    subject = xml.find("pbcore:subject", PbcoreXmlElement::PBCORE_NAMESPACE)
    return nil if subject.empty? || subject[0].child.nil?
    subjname = subject[0].child.content

    authority = xml.find("pbcore:subjectAuthorityUsed", PbcoreXmlElement::PBCORE_NAMESPACE)
    authorityused = (authority.empty? || authority[0].child.nil?) ? nil : authority[0].child.content

    Subject.find_or_create_by_subject_and_subject_authority(subjname, authorityused)
  end

  def safe_to_delete?
    assets.empty?
  end
end
