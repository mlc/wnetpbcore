class FormatColorsController < PicklistsController
  def set_standard_pbcore
    @standard_pbcore =
      [
       "B&W", "Grayscale", "Color", "B&W with grayscale sequences",
       "B&W with color sequences", "Grayscale with B&W sequences",
       "Grayscale with color sequences", "Color with B&W sequences",
       "Color with grayscale sequences", "Other"
      ].to_set.freeze
  end
end
