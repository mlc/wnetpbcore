class DescriptionType < ActiveRecord::Base
  include Picklist
  has_many :descriptions
end
