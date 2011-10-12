class InstantiationMediaTypesController < PicklistsController
  def set_standard_pbcore
    @standard_pbcore =
      [
       "Animation", "Artifact", "Collection", "Dataset", "Event",
       "Interactive Resource", "Moving Image", "Physical Object", "Presentation",
       "Service", "Software", "Sound", "Static Image", "Text"
      ].to_set.freeze
  end
end
