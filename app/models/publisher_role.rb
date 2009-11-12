class PublisherRole < ActiveRecord::Base
  include Picklist
  has_many :publishers
  quick_column :name
  
  def safe_to_delete?
    publishers.size == 0
  end
end
