class Genre < ActiveRecord::Base
  include PbcoreXmlElement
  include Picklist
  stampable

  has_and_belongs_to_many :assets
  xml_text_field :name
  xml_attributes "source" => :genre_authority_used

  quick_column 'CONCAT(name, " (", COALESCE(genre_authority_used, ""), ")")'

  # we use the standard PbcoreXmlElement definition of to_xml, but we have
  # to customize the from_xml direction...
  # FIXME: This is the problem when trying to save a record, it fails right here.
  #        Overridden behavior from the standard PbcoreXmlElement way.
  #        What I need to figure out is how to conform this to the new 2.0 schema
  #        that is using attributes.
  def self.from_xml(xml)
    genre = xml.find("pbcore:genre", PbcoreXmlElement::PBCORE_NAMESPACE)
    return nil if genre.empty? || genre[0].child.nil?
    genrename = genre[0].child.content

    authority = xml.find("pbcore:genreAuthorityUsed", PbcoreXmlElement::PBCORE_NAMESPACE)
    authorityused = (authority.empty? || authority[0].child.nil?) ? nil : authority[0].child.content

    Genre.find_or_create_by_name_and_genre_authority_used(genrename, authorityused)
  end

  def safe_to_delete?
    assets.empty?
  end
end
