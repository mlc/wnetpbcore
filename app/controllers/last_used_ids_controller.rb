class LastUsedIdsController < ApplicationController
  filter_access_to :all

  def index
    @identifier_sources = IdentifierSource.find_by_sql(
      "SELECT identifier_sources.*, MAX(identifier) AS maxid FROM identifiers INNER JOIN identifier_sources ON identifiers.identifier_source_id = identifier_sources.id GROUP BY identifier_source_id ORDER BY name"
    )

    @format_identifier_sources = FormatIdentifierSource.find_by_sql(
       "SELECT format_identifier_sources.*, MAX(format_identifier) AS maxid FROM format_ids INNER JOIN format_identifier_sources ON format_ids.format_identifier_source_id = format_identifier_sources.id GROUP BY format_identifier_source_id ORDER BY name"
    )
  end
end
