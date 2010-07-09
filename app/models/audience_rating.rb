class AudienceRating < ActiveRecord::Base
  include Picklist
  has_and_belongs_to_many :assets
  quick_column :name

  def safe_to_delete?
    assets.count == 0
  end
end
