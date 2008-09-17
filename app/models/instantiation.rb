class Instantiation < ActiveRecord::Base
  belongs_to :asset
  has_many :format_ids
  belongs_to :format
  belongs_to :format_media_type
  belongs_to :format_generation
  belongs_to :format_color
  has_many :essence_tracks
  has_many :date_availables
  has_many :annotations

  validates_presence_of :format_location
end
