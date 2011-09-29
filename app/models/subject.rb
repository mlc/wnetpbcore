class Subject < ActiveRecord::Base
  include PbcoreXmlElement
  include Picklist

  has_and_belongs_to_many :assets
  stampable

  quick_column 'IF(subject_authority IS NULL, subject, CONCAT(subject, " (", subject_authority, ")"))'
  xml_text_field :subject
  xml_attributes "source" => :subject_authority

  def name
    subject
  end

  # we use the standard PbcoreXmlElement definition of to_xml, but we have
  # to customize the from_xml direction...
  def self.from_xml(xml)
    subject = xml.content
    source = xml['source']
    
    Subject.find_or_create_by_subject_and_subject_authority(subject, source)
  end

  def safe_to_delete?
    assets.empty?
  end
end
