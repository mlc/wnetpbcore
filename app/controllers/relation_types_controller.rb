class RelationTypesController < PicklistsController
  def set_standard_pbcore
    @standard_pbcore =
      [
       "Has Format", "Is Format Of", "Has Part", "Is Part Of", "Has Version",
       "Is Version Of", "References", "Is Referenced By", "Replaces",
       "Is Replaced By", "Requires", "Is Required By", "Other"
      ].to_set.freeze
  end
end
