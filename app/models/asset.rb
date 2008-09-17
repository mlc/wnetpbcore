class Asset < ActiveRecord::Base
  has_many :identifiers, :dependent => :destroy
  has_many :titles, :dependent => :destroy
  has_many :subjects
  has_many :descriptions
  has_many :relations
  has_many :covergaes
  has_and_belongs_to_many :audience_levels
  has_and_belongs_to_many :audience_ratings
  has_many :creators
  has_many :contributors
  has_many :publishers
  has_many :rights_summaries
  has_many :instantiations
  has_many :extensions
end
