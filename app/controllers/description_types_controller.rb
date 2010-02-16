class DescriptionTypesController < PicklistsController
  def set_standard_pbcore
    @standard_pbcore = [
     "Abstract", "Package", "Project", "Collection", "Series", "Episode",
     "Program", "Segment", "Clip", "Selection or Excerpt", "Table of Contents",
     "Segment Sequence", "Rundown", "Playlist", "Script", "Transcript",
     "Descriptive Audio", "PODS", "PSD", "Anecdotal Comments & Reflections",
     "Listing Services", "Content Flags", "Other"
    ].to_set.freeze
  end
end
