class ValueList < ActiveRecord::Base
  has_many :values
  validates_presence_of :table_name
  validates_presence_of :fixed_field_name
  validates_presence_of :fixed_field_value

  def name
    table = table_name.capitalize.constantize
  end

  PERMITTED_FIELDS = {
    :title => [:title_type_id]
  }
end
