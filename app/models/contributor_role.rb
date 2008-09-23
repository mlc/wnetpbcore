class ContributorRole < ActiveRecord::Base
  include Picklist
  has_many :contributors
end
