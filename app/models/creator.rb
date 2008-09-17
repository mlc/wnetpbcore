class Creator < ActiveRecord::Base
  belongs_to :asset
  belongs_to :creator_role
end
