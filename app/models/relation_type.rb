class RelationType < ActiveRecord::Base
  include Picklist
  has_many :relations
  quick_column :name
  
  def safe_to_delete?
    relations.size == 0
  end
end
