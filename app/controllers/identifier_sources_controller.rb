class IdentifierSourcesController < ApplicationController
  filter_access_to :all
  before_filter :get_identifier_source, :only => [:edit, :update, :destroy]
  
  def index
    respond_to do |format|
      format.html do
        @identifier_sources = IdentifierSource.paginate(:order => "name ASC", :page => params[:page], :per_page => 50) # - [IdentifierSource::OUR_UUID_SOURCE]
      end
      
      # AJAX Autocomplete for edit (perhaps create) form
      format.json do
        render :json => (@klass.find(:all, :conditions => ["name like ? and visible = 1", "%#{params[:term]}%"],
                                    :order => "name ASC") - [IdentifierSource::OUR_UUID_SOURCE]).map(&:name)
      end
    end
  end
  
  def edit
  end
  
  def update
    if @identifier_source.update_attributes(params[:identifier_source])
      redirect_to identifier_sources_url, :notice => "Successfully updated Identifier Source"
    else
      render :action => "edit"
    end
  end
  
  def new
    @identifier_source = IdentifierSource.new
  end
  
  def create
    @identifier_source = IdentifierSource.new(params[:identifier_source])
    
    if @identifier_source.save
      redirect_to identifier_sources_url, :notice => "Successfully created Identifier Source"
    else
      render :action => "new"
    end
  end
  
  def destroy
    if @identifier_source.safe_to_delete?
      @identifier_source.destroy
      redirect_to :back, :notice => "Successfully deleted Identifier Source"
    else
      redirect_to :back, :notice => "Unable to delete Identifier Source"
    end
  end
  
  protected
  def get_identifier_source
    @identifier_source = IdentifierSource.find(params[:id])
  end
end
