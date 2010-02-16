class ContributorRolesController < PicklistsController
  def set_standard_pbcore
    @standard_pbcore =
      [
       "Actor", "Advisor", "Anchor", "Arranger", "Artist", "Assistant Cameraman",
       "Assistant Director", "Assistant Editor", "Assistant Producer - Film",
       "Assistant Researcher", "Assistant Stage Manager",
       "Assistant to the Producer", "Assistant Unit Manager",
       "Associate Director", "Associate Producer", "Audio", "Audio Assistant",
       "Audio Editor", "Audio Engineer", "Audio Mixer", "Author",
       "Boom Operator", "Camera Assistant", "Cameraperson", "Casting",
       "Chief Camera - Segment", "Cinematographer", "Commentary Editor",
       "Commentator", "Community Coordinator", "Composer", "Concept",
       "Conductor", "Contributor", "Co-Producer", "Crane", "Director",
       "Director - Artistic", "Director - Dance", "Director - Doc Material",
       "Director - Segment", "Edit Programmer", "Editor", "Editor - graphics",
       "Editor - Segment", "Engineer", "Essayist", "Executive Producer",
       "Fashion Consultant", "Film Editor", "Film Sound", "Filmmaker",
       "Floor Manager", "Funder", "Gaffer", "Graphic Designer", "Graphics",
       "Guest", "Host", "Illustrator", "Instrumentalist", "Intern",
       "Interpreter", "Interviewee", "Interviewer", "Lecturer", "Lighting",
       "Lighting Assistant", "Lighting Director", "Make-Up",
       "Mobile Unit Supervisor", "Moderator", "Music Assistant",
       "Music Coordinator", "Music Director", "Musical Staging", "Musician",
       "Narrator", "News Director", "Panelist", "Performer", "Performing Group",
       "Photographer", "Post-prod Audio", "Post-prod Supervisor", "Producer",
       "Producer - Segment", "Production Assistant", "Production Manager",
       "Production Personnel", "Production Personnel", "Production Secretary",
       "Production Unit", "Project Director", "Publicist", "Reader",
       "Recording engineer", "Recordist", "Reporter", "Researcher",
       "Scenic Design", "Senior Editor", "Senior Researcher", "Sound",
       "Sound Mixer", "Speaker", "Staff Volunteer", "Stage Manager",
       "Still Photography", "Studio Technician", "Subject", "Switcher",
       "Synthesis", "Synthesis Musician", "Talent Coordinator",
       "Technical Consultant", "Technical Director", "Technical Production",
       "Theme Music", "Titlist", "Translator", "Unit Manager", "Video",
       "Videotape Assembly", "Videotape Editor", "Videotape Engineer",
       "Videotape Recordist", "Vidifont Operator", "Vocalist", "VTR Recordist",
       "Wardrobe", "Writer", "Other"
      ].to_set.freeze
  end
end
