class MakeInitialVersions < ActiveRecord::Migration
  def self.up
    count = 0
    rows = Asset.find(:all, :conditions => ["id > ?", 0], :limit => 250, :include => Asset::ALL_INCLUDES)
    while rows.any?
      versions = []
      rows.each do |asset|
        versions << '(' + [asset.id, asset.to_xml, asset.updater_id, asset.updated_at, asset.updated_at].map{|x| Version.connection.quote(x)}.join(',') + ')'
      end
      Version.connection.execute("INSERT INTO versions (asset_id, body, creator_id, created_at, updated_at) VALUES #{versions.join(',')}")
      count += versions.size
      puts "#{count} versions saved..."
      rows = Asset.find(:all, :conditions => ["id > ?", rows.last.id], :limit => 250, :include => Asset::ALL_INCLUDES)
    end
  end

  def self.down
    Version.delete_all
  end
end
