class FormatGeneration < ActiveRecord::Base
  include Picklist
  has_many :instantiations
end
