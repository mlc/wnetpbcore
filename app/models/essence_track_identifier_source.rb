class EssenceTrackIdentifierSource < ActiveRecord::Base
  include Picklist
  has_many :essence_tracks
  quick_column :name
  
  def safe_to_delete?
    essence_tracks.size == 0
  end
end
