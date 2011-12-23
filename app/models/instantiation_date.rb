class InstantiationDate < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :instantiation
  belongs_to :instantiation_date_type
  stampable

  accepts_nested_attributes_for :instantiation_date_type
  
  def instantiation_date_type_name
    instantiation_date_type.try(:name)
  end
  
  def instantiation_date_type_name=(name)
    self.instantiation_date_type = InstantiationDateType.find_by_name(name) if name.present?
  end

  xml_text_field :date
  xml_attributes "dateType" => :instantiation_date_type
end
