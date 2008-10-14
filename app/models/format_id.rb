class FormatId < ActiveRecord::Base
  belongs_to :instantiation

  validates_length_of :format_identifier, :minimum => 1
end
