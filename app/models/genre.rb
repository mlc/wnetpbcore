class Genre < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  xml_string "genre", :genre
  xml_string "genreAuthorityUsed", :genre_authority_used
end
