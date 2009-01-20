class Genre < ActiveRecord::Base
  include PbcoreXmlElement
  has_and_belongs_to_many :assets
  xml_string "genre", :name
  xml_string "genreAuthorityUsed", :genre_authority_used

  # we use the standard PbcoreXmlElement definition of to_xml, but we have
  # to customize the from_xml direction...
  def self.from_xml(xml)
    genre = xml.find("pbcore:genre", PbcoreXmlElement::PBCORE_NAMESPACE)
    return nil if genre.empty? || genre[0].child.nil?
    genrename = genre[0].child.content

    authority = xml.find("pbcore:genreAuthorityUsed", PbcoreXmlElement::PBCORE_NAMESPACE)
    authorityused = (authority.empty? || authority[0].child.nil?) ? nil : authority[0].child.content

    Genre.find_or_create_by_name_and_genre_authority_used(genrename, authorityused)
  end
end
