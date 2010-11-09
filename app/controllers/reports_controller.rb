class ReportsController < ApplicationController
  filter_access_to :all, :require => :index

  REPORTS = {
    :genres => "select count(*) as count, genres.name, genres.genre_authority_used from assets_genres left join genres on assets_genres.genre_id = genres.id group by assets_genres.genre_id",
    :subjects => "select count(*) as count, subjects.subject, subjects.subject_authority from assets_subjects left join subjects on assets_subjects.subject_id = subjects.id group by assets_subjects.subject_id",
    :contributors_count => "select count(*) as count, contributor from contributors group by contributor",
    :contributors_all => "select contributors.contributor, assets.uuid, contributor_roles.name from contributors left join contributor_roles on contributor_roles.id = contributors.contributor_role_id, assets where assets.id = contributors.asset_id",
    :publishers_count => "select count(*) as count, publisher from publishers group by publisher",
    :publishers_all => "select publishers.publisher, assets.uuid, publisher_roles.name from publishers left join publisher_roles on publisher_roles.id = publishers.publisher_role_id, assets where assets.id = publishers.asset_id",
    :creators_count => "select count(*) as count, creator from creators group by creator",
    :creators_all => "select creators.creator, assets.uuid, creator_roles.name from creators left join creator_roles on creator_roles.id = creators.creator_role_id, assets where assets.id = creators.asset_id"
  }

  def index
    @reports = REPORTS.keys.map(&:to_s).sort
  end

  def method_missing(action, *args)
    if REPORTS.has_key?(action.to_sym)
      sql = REPORTS[action.to_sym]
      result = ActiveRecord::Base.connection.execute(sql)

      headers.merge!(
        'Content-Type' => 'text/csv; charset=utf-8',
        'Content-Disposition' => "attachment; filename=#{action.to_s}.csv",
        'Content-Transfer-Encoding' => 'binary',
        'Cache-Control' => 'private'
      )

      render :text => proc { |response, output|
        csv = FCSV.new(output)
        csv << result.fetch_fields.map(&:name)
        result.each do |row|
          csv << row
        end
        result.free
      }
    else
      super
    end
  end

  def respond_to?(method)
    REPORTS.has_key?(method.to_sym) || super
  end
end
