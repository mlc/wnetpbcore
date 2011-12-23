class InstantiationColor < ActiveRecord::Base
  include Picklist
  has_many :instantiations
  quick_column :name
  
  named_scope :visible, :conditions => { :visible => true }, :order => "name ASC"
  
  def safe_to_delete?
    instantiations.size == 0
  end
end
