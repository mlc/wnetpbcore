class CreatorRolesController < PicklistsController
  def set_standard_pbcore
    @standard_pbcore =
      [
       "Artist", "Associate Producer", "Cinematographer", "Composer",
       "Co-Producer", "Creator", "Director", "Editor", "Essayist",
       "Executive Producer", "Host", "Illustrator", "Interviewer", "Moderator",
       "Photographer", "Producer", "Production Unit", "Reporter", "Writer",
       "Other"
      ].to_set.freeze
  end
end
