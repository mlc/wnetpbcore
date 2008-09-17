class Contributor < ActiveRecord::Base
  belongs_to :asset
  belongs_to :contributor_role
end
