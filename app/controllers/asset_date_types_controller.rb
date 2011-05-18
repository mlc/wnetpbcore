class AssetDateTypesController < PicklistsController
  def set_standard_pbcore
    @standard_pbcore = %w(availableEnd availableStart broadcast 
      content created issued portrayed published revised).to_set.freeze
  end
end
