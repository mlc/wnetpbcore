class Identifier < ActiveRecord::Base
  belongs_to :asset
  belongs_to :identifier_source
end
