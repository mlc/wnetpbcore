class Subject < ActiveRecord::Base
  include PbcoreXmlElement
  include Picklist

  has_and_belongs_to_many :assets
  stampable

  quick_column 'IF(subject_authority IS NULL, subject, CONCAT(subject, " (", subject_authority, ")"))'
  xml_text_field :subject
  xml_attributes({"source" => :subject_authority }, { "ref" => :ref })

  def name
    subject
  end

  # we use the standard PbcoreXmlElement definition of to_xml, but we have
  # to customize the from_xml direction...
  def self.from_xml(xml)
    xml_subject = xml.content
    xml_source = xml['source']
    xml_ref = xml['ref']
    
    subject = Subject.find_or_create_by_subject_and_subject_authority(xml_subject, xml_source)
    unless xml_ref.blank?
      if subject.ref.blank?
        subject.ref = xml_ref
        subject.save
      end
    end
    subject
  end

  def safe_to_delete?
    assets.empty?
  end
end
