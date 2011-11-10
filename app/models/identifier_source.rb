class IdentifierSource < ActiveRecord::Base
  include Picklist
  has_many :identifiers
  quick_column :name
  stampable

  named_scope :visible, :conditions => { :visible => true }, :order => "name ASC"

  OUR_UUID_SOURCE = find_or_create_by_name("pbcore XML database UUID") rescue nil
  
  def safe_to_delete?
    identifiers.count == 0
  end

  def max_identifier
    a = self.class.find_by_sql(["SELECT MAX(CAST(identifier AS SIGNED INTEGER)) AS maxid FROM identifiers WHERE identifier_source_id = ?", self.id])[0]["maxid"]
    a.nil? ? 0 : a.to_i
  end

  def next_sequence
    old = self.sequence.nil? ? max_identifier : sequence
    update_attribute(:sequence, old + 1)
    old + 1
  end
end
