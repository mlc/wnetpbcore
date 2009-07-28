class SubjectsController < PicklistsController
  def index
    @emit_warning = should_emit_warning
    @objects = @klass.all(:order => "subject ASC")
  end

  protected
  def should_emit_warning; false; end
end
