class TitleTypeCategory < ActiveRecord::Base
  has_many :title_types, :foreign_key => 'category_id'
end
