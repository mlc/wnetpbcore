class CreatorRole < ActiveRecord::Base
  include Picklist
  has_many :creators
end
