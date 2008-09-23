class IdentifierSource < ActiveRecord::Base
  include Picklist
  has_many :identifiers
end
