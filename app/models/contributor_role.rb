class ContributorRole < ActiveRecord::Base
  include Picklist
  has_many :contributors
  quick_column :name
  
  def safe_to_delete?
    contributors.size == 0
  end
end
