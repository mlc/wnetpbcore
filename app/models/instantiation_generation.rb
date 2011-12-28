class InstantiationGeneration < ActiveRecord::Base
  include Picklist
  has_and_belongs_to_many :instantiations
  quick_column :name

  named_scope :visible, :conditions => ["visible = 1"], :order => "name asc"

  def safe_to_delete?
    instantiations.size == 0
  end
  
  def self.from_xml(xml)
    xml_instantiation_generation = xml.content
    instantiation_generation = InstantiationGeneration.find_or_create_by_name(xml_instantiation_generation)
  end
end
