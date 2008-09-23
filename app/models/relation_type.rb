class RelationType < ActiveRecord::Base
  include Picklist
  has_many :relations
end
