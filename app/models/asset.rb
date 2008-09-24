class Asset < ActiveRecord::Base
  has_many :identifiers, :dependent => :destroy
  has_many :titles, :dependent => :destroy
  has_many :subjects
  has_many :descriptions
  has_many :genres
  has_many :relations
  has_many :covergaes
  has_and_belongs_to_many :audience_levels
  has_and_belongs_to_many :audience_ratings
  has_many :creators
  has_many :contributors
  has_many :publishers
  has_many :rights_summaries
  has_many :instantiations
  has_many :extensions
  
  def self.from_xml(xml)
    if xml.is_a?(String)
      parser = XML::Parser.new
      parser.string = xml
      xml = parser.parse.root
    end
    
    asset = Asset.new
    asset.identifiers = xml.find('pbcore:pbcoreIdentifier', PBCORE_NAMESPACE).map{|elem| Identifier.from_xml(elem)}
    asset.titles = xml.find('pbcore:pbcoreTitle', PBCORE_NAMESPACE).map{|elem| Title.from_xml(elem)}
    
    asset
  end
end
