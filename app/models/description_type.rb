class DescriptionType < ActiveRecord::Base
  include Picklist
  has_many :descriptions
  
  def safe_to_delete?
    descriptions.size == 0
  end
end
