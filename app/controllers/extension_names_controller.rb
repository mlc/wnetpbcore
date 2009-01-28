class ExtensionNamesController < PicklistsController
  def index
    @emit_warning = should_emit_warning
    @objects = @klass.all(:order => "description ASC")
  end

  protected
  def should_emit_warning
    "<strong>Note:</strong> Extension names are merely aliases for extension authority / key combinations. Modifying them only affects the display in this tool, not in the underlying PBCore records."
  end
end
