class Title < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :title_type
  belongs_to :asset
  stampable
  
  accepts_nested_attributes_for :title_type

  xml_text_field :title
  xml_attributes "titleType", "source", "ref", "annotation", "startTime", "endTime", "timeAnnotation"
  
  def title_type_name
    title_type.try(:name)
  end
  
  def title_type_name=(name)
    self.title_type = TitleType.find_by_name(name) if name.present?
  end
  
end
