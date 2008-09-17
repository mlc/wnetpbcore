class Relation < ActiveRecord::Base
  belongs_to :asset
  belongs_to :relation_type
end
