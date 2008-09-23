# A lot of PBCore fields are extensible picklists.
module Picklist
  def self.find_or_create_by_name(name)
    find_by_name(name) || new(:name => name)
  end
end
