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
    set_property :enable_star => 1
    set_property :min_infix_len => 3
  end
  
  def self.async_reindex
    begin
      MiddleMan.worker(:indexing_worker).async_reindex
    rescue
      reindex
    end
  end

  def self.regenerate_all(blocksize = 100)
    offset = 1
    begin
      ThinkingSphinx.updates_enabled = false

      while true do
        assets = Asset.find(:all, :include => Asset::ALL_INCLUDES, :offset => offset, :limit => blocksize)
        break if assets.empty?
        assets.each do |asset|
          asset.update_asset_terms
          asset.asset_terms.save
        end
        offset += assets.size
        puts "#{offset-1} asset_terms regenerated"
      end
    ensure
      ThinkingSphinx.updates_enabled = true
      reindex
    end
  end

  def self.reindex
    Kernel.system("rake", "RAILS_ENV=#{RAILS_ENV}", "thinking_sphinx:index")
  end
end
