class IdentifierSourcesController < PicklistsController
  def index
    @emit_warning = should_emit_warning
    @objects = @klass.all(:order => "name ASC") - [IdentifierSource::OUR_UUID_SOURCE]
  end

  protected
  def should_emit_warning; false; end
end
