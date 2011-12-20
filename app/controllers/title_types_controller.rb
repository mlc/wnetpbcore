class TitleTypesController < PicklistsController
  def set_standard_pbcore
    @standard_pbcore = {
      "Express Relationships" => ["Package", "Project", "Collection", "Series",
                                  "Episode", "Program", "Segment", "Clip",
                                  "Scene", "Shot", "Selection or Excerpt",
                                  "Alternative"],
      "Accessibility Options" => ["Caption File", "Descriptive Audio",
                                  "Transcript File"],
      "Audio Recordings" => ["Music", "Nature/ambient sound", "Song", "Voice"],
      "Imagery" => ["Art Work", "Chart", "Diagram", "Drawing", "Graphic",
                    "Map", "Model", "Photograph", "Picture", "Postcard",
                    "Poster"],
      "Interactive Experiences" => ["Courseware Class", "Courseware Module",
                                    "Drill and Practice", "Game",
                                    "Model Building", "Quiz",
                                    "Reflection Activity", "Role Play",
                                    "Self Assessment", "Simulation", "Test",
                                    "Web page/site"],
      "Presentations" => ["Linear Presentation", "Multimedia Presentation",
                          "Slide Show", "Traditional Academic Poster",
                          "Electronic Academic Poster", "Kiosk Event"],
      "Text Documents" => ["Syllabus", "Lesson Plan", "Study Guide",
                           "Teacher's Guide", "Article", "Book", "Chapter",
                           "Issue", "Lyrics", "Manuscript", "Periodical",
                           "Score"],
      "Media Production & Versioning" => ["Abridged Version", "Air Version",
                                          "Captioned Version",
                                          "Cell Phone Version",
                                          "Full Version", "iPod Version",
                                          "Packaging Version",
                                          "Pledge Version",
                                          "Published Version", "Re-Title",
                                          "Web Version", "Working Title"],
      "Other" => ["Other"]
    }.values.flatten.to_set.freeze
  end
 
end
