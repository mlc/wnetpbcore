class GenresController < PicklistsController
  before_filter :get_genre, :only => [:edit, :update, :destroy]
  
  def index
    respond_to do |format|
      format.html { @genres = Genre.paginate(:order => "name ASC", :page => params[:page], :per_page => 50) }
      format.json do
        render :json => @klass.find(:all, 
                                    :conditions => ["name like ? and visible = 1", "%#{params[:q]}%"], 
                                    :order => "name ASC",
                                    :limit => 100).collect { |g| { :id => g.id, :name => "#{g.name} (#{g.genre_authority_used})"}}
      end
    end
  end
  
  def new
    @genre = Genre.new
  end

  def create
    @genre = Genre.new(params[:genre])

    respond_to do |format|
      if @genre.save
        flash[:message] = "Successfully created new genre."
        format.html { redirect_to genres_url }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @genre.update_attributes(params[:genre])
        flash[:message] = "Successfully updated genre."
        format.html { redirect_to genres_url }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @genre.destroy
    flash[:message] = "Successfully destroyed #{@genre.name}"
    respond_to do |format|
      format.html { redirect_to genres_url }
    end
  end

protected
  def get_genre
    @genre = Genre.find(params[:id])
  end

  protected
  def should_emit_warning; false; end
end
