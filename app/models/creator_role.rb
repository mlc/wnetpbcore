class CreatorRole < ActiveRecord::Base
  include Picklist
  has_many :creators
  
  def safe_to_delete?
    creators.size == 0
  end
end
