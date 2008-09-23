class FormatMediaType < ActiveRecord::Base
  include Picklist
  has_many :instantiations
end
