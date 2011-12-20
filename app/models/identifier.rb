class Identifier < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  belongs_to :identifier_source
  stampable

  accepts_nested_attributes_for :identifier_source

  xml_text_field :identifier
  xml_attributes({"source" => :identifier_source}, "ref", "annotation")
  
  validates_length_of :identifier, :minimum => 1
  validates_presence_of :identifier_source
  
  def identifier_source_name
    identifier_source.try(:name)
  end
  
  def identifier_source_name=(name)
    self.identifier_source = IdentifierSource.find_by_name(name) if name.present?
  end
  
  # This is a virtual attribute that allows for "ref" to be stored in the 
  # IdentifierSource model
  def ref
    identifier_source.try(:ref)
  end
  
  def ref=(reference)
    self.identifier_source.ref = reference if reference.present?
  end
  
  # TODO: What is this? Investigate.
  def validate
    super
    unless doing_xml? || identifier_source.nil? || identifier_source.regex.nil? ||
        Regexp.new(identifier_source.regex).match(identifier)
      self.errors.add("identifier", "does not match the rules for the selected identifier source")
    end
  end
end
