class AudienceRating < ActiveRecord::Base
  include Picklist
  has_and_belongs_to_many :assets
end
