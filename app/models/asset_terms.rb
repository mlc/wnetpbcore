class AssetTerms < ActiveRecord::Base
  belongs_to :asset
  
  define_index do
    indexes :identifier
    indexes :title
    indexes :subject
    indexes :description
    indexes :genre
    indexes :relation
    indexes :coverage
    indexes :audience_level
    indexes :audience_rating
    indexes :creator
    indexes :contributor
    indexes :publisher
    indexes :rights
    indexes :extension
    indexes :location
    indexes :annotation
    indexes :date
    has :asset_id
    has :created_at
    has :updated_at
    
    set_property :delta => true
  end
  
  def self.async_reindex
    begin
      MiddleMan.worker(:indexing_worker).async_reindex
    rescue
      reindex
    end
  end
  
  def reindex
    Kernel.system("rake", "RAILS_ENV=#{RAILS_ENV}", "thinking_sphinx:index")
  end
end
