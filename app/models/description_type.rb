class DescriptionType < ActiveRecord::Base
  include Picklist
  has_many :descriptions
  quick_column :name
  
  def safe_to_delete?
    descriptions.size == 0
  end
end
