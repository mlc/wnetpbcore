class FormatMediaType < ActiveRecord::Base
  include Picklist
  has_many :instantiations
  quick_column :name

  def safe_to_delete?
    instantiations.size == 0
  end
end
