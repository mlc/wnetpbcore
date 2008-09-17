class Title < ActiveRecord::Base
  belongs_to :title_type
  belongs_to :asset
end
