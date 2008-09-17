class Publisher < ActiveRecord::Base
  belongs_to :asset
  belongs_to :publisher_role
end
