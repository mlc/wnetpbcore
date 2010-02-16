class PublisherRolesController < PicklistsController
  def set_standard_pbcore
    @standard_pbcore =
      [
       "Copyright Holder", "Distributor", "Presenter", "Publisher",
       "Release Agent", "Other"
      ].to_set.freeze
  end
end
