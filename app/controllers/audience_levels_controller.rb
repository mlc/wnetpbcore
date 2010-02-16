class AudienceLevelsController < PicklistsController
  def set_standard_pbcore
    @standard_pbcore =
      [
       "K-12 (general)", "Pre-school (kindergarten)", "Primary (grades 1-6)",
       "Intermediate (grades 7-9)", "High School (grades 10-12)", "College",
       "Post Graduate", "General Education", "Educator", "Vocational", "Adult",
       "Special Audiences", "General", "Male", "Female", "Other"
      ].to_set.freeze
  end
end
