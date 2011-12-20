class GenresController < PicklistsController
  def index
    respond_to do |format|
      format.html { super }
      format.json do
        render :json => @klass.find(:all, 
                                    :conditions => ["name like ? and visible = 1", "%#{params[:q]}%"], 
                                    :order => "name ASC",
                                    :limit => 100).collect { |g| { :id => g.id, :name => "#{g.name} (#{g.genre_authority_used})"}}
      end
    end
  end

  protected
  def should_emit_warning; false; end
end
