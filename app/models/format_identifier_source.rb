class FormatIdentifierSource < ActiveRecord::Base
  include Picklist
  has_many :format_ids

  OUR_UUID_SOURCE = find_or_create_by_name("pbcore XML database UUID") rescue nil
  
  def safe_to_delete?
    self.id != OUR_UUID_SOURCE.id && format_ids.count == 0
  end
end
