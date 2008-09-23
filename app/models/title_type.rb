class TitleType < ActiveRecord::Base
  include Picklist
  belongs_to :category, :class_name => 'TitleTypeCategory'
  has_many :titles
end
