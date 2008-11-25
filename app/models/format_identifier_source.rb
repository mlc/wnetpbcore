class FormatIdentifierSource < ActiveRecord::Base
  include Picklist
  has_many :format_ids
  
  def safe_to_delete?
    format_ids.count == 0
  end
end
