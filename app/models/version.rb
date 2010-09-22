class Version < ActiveRecord::Base
  belongs_to :asset
  stampable
end
