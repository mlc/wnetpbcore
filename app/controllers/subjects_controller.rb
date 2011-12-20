class SubjectsController < PicklistsController
  def index
    respond_to do |format|
      format.html do
        @emit_warning = should_emit_warning
        @objects = @klass.all(:order => "subject ASC", :limit => 100)
        render :template => 'picklists/index'
      end
      format.json do
        render :json => @klass.find(:all, 
                                    :conditions => ["subject like ? and visible = 1", "%#{params[:q]}%"],
                                    :order => "subject ASC",
                                    :limit => 100).collect { |s| { :id => s.id, :name => "#{s.subject} (#{s.subject_authority})"}}
      end
    end
  end

  protected
  def should_emit_warning; false; end
end
