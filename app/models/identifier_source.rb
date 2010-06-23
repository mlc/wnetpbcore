class IdentifierSource < ActiveRecord::Base
  include Picklist
  has_many :identifiers
  stampable
  
  OUR_UUID_SOURCE = find_or_create_by_name("pbcore XML database UUID") rescue nil
  
  def safe_to_delete?
    identifiers.count == 0
  end
end
