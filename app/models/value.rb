class Value < ActiveRecord::Base
  belongs_to :value_list

  PERMITTED_FIELDS = {
    :title => [:title_type_id]
  }
end
