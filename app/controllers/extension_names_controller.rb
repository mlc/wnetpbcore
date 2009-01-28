class ExtensionNamesController < PicklistsController
  def index
    @emit_warning = should_emit_warning
    @objects = @klass.all(:order => "description ASC")
  end

  protected
  def should_emit_warning; false; end
end
