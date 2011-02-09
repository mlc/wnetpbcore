class SlowReplacer < Struct.new(:field, :from, :to, :user, :email)
  def perform
    self.user = User.find(self.user) unless self.user.is_a?(ActiveRecord::Base)
    klass, method = find_update_info
    records = klass.find(:all, :conditions => {method => from})
    unless records.empty?
      Asset.transaction do
        record_ids = records.map(&:id)
        asset_ids = records.map(&:asset_id).uniq
        klass.update_all({method => to}, "id in (#{record_ids.join(',')})")
        asset_ids.in_groups_of(25) do |group|
          assets = Asset.find(group, :include => Asset::ALL_INCLUDES)
          assets.each do |asset|
            asset.index
            Version.create(:asset => asset, :body => asset.to_xml, :creator_id => user.id)
          end
        end
      end
      Sunspot.commit
    end
  end

  def find_update_info
    # yes, this could just be field.to_s.capitalize.constantize but
    # maybe not in future
    case field.to_sym
    when :title
      [Title, :title]
    when :contributor
      [Contributor, :contributor]
    when :publisher
      [Publisher, :publisher]
    when :creator
      [Creator, :creator]
    else
      raise "invalid field."
    end
  end

  def self.allowed_fields
    [:title, :contributor, :publisher, :creator].map(&:to_s)
  end
end
