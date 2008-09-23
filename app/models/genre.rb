class Genre < ActiveRecord::Base
  include Picklist
  has_many :assets
end
