class FormatIdentifierSource < ActiveRecord::Base
  include Picklist
  has_many :format_ids

  OUR_UUID_SOURCE = find_or_create_by_name("pbcore XML database UUID") rescue nil
  OUR_ONLINE_SOURCE = find_or_create_by_name("pbcore XML database online asset") rescue nil
  OUR_THUMBNAIL_SOURCE = find_or_create_by_name("pbcore XML database thumbnail") rescue nil
  
  def safe_to_delete?
    !([OUR_UUID_SOURCE.id, OUR_ONLINE_SOURCE.id, OUR_THUMBNAIL_SOURCE.id].include?(self.id)) && format_ids.count == 0
  end
end
