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
  def self.from_xml(xml)
    genre = xml.content
    source = xml['source']
    
    Genre.find_or_create_by_name_and_genre_authority_used(genre, source)
  end

  def safe_to_delete?
    assets.empty?
  end
end
