class IdentifierSourcesController < PicklistsController
  def index
    @emit_warning = should_emit_warning

    respond_to do |format|
      
      format.html do
        @objects = @klass.all(:order => "name ASC") - [IdentifierSource::OUR_UUID_SOURCE]
        render :template => "picklists/index"
      end
      
      # AJAX Autocomplete for edit (perhaps create) form
      format.json do
        render :json => (@klass.find(:all, :conditions => ["name like ? and visible = 1", "%#{params[:term]}%"],
                                    :order => "name ASC") - [IdentifierSource::OUR_UUID_SOURCE]).map(&:name)
      end
    
    end
  end

  protected
  def should_emit_warning; false; end
end
