class TitleType < ActiveRecord::Base
  belongs_to :category, :class_name => 'TitleTypeCategory'
  has_many :titles
end
