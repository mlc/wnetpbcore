class RelationType < ActiveRecord::Base
  include Picklist
  has_many :relations
  
  def safe_to_delete?
    relations.size == 0
  end
end
