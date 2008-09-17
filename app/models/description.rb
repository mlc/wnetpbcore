class Description < ActiveRecord::Base
  belongs_to :asset
  belongs_to :description_type
end
