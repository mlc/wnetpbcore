class CreatorRole < ActiveRecord::Base
  include Picklist
  has_many :creators
  quick_column :name
  
  def safe_to_delete?
    creators.size == 0
  end
end
