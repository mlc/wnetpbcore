class Value < ActiveRecord::Base
  belongs_to :value_list

  validates_presence_of :value_list_id
  validates_presence_of :value
  validates_uniqueness_of :value, :scope => [:value_list_id]
end
