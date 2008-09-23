class PublisherRole < ActiveRecord::Base
  include Picklist
  has_many :publishers
end
